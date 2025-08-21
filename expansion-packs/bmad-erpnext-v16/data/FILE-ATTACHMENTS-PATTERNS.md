# 🚨 FILE ATTACHMENTS PATTERNS - UPLOAD & DOWNLOAD SYSTEM

## CRITICAL: Secure File Management = Data Protection

This document contains MANDATORY patterns for file uploads, downloads, and attachment management in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S FILE SYSTEM

### File Storage Architecture:

| Storage Type | Location | Use For | Security Level |
|-------------|----------|---------|----------------|
| **Public Files** | `/public/files/` | Images, public documents | Low |
| **Private Files** | `/private/files/` | Sensitive documents | High |
| **Temp Files** | `/tmp/` | Processing uploads | None |
| **Backup Files** | `/private/backups/` | Database backups | Maximum |

### File Access Control:

- **Public Files**: Accessible via direct URL
- **Private Files**: Require authentication and permission checks
- **Attached Files**: Linked to specific documents with inheritance permissions
- **Orphaned Files**: Files not attached to any document (cleanup required)

---

## 🔴 FILE UPLOAD PATTERNS

### Basic File Upload Implementation:

```python
# [app]/api/file_upload.py

import frappe
from frappe import _
from frappe.utils.file_manager import save_file
import os
import mimetypes

@frappe.whitelist()
def upload_document(doctype, docname, file_data, filename, is_private=1):
    """Upload file and attach to document"""
    
    # Validate permissions
    if not frappe.has_permission(doctype, "write", docname):
        frappe.throw(_("Insufficient permissions to attach files"), frappe.PermissionError)
    
    # Validate file
    validate_file_upload(file_data, filename)
    
    # Save file
    file_doc = save_file(
        fname=filename,
        content=file_data,
        dt=doctype,
        dn=docname,
        is_private=int(is_private)
    )
    
    # Log file upload
    frappe.get_doc({
        "doctype": "Activity Log",
        "subject": f"File uploaded: {filename}",
        "content": f"File {filename} uploaded to {doctype} {docname}",
        "reference_doctype": doctype,
        "reference_name": docname
    }).insert(ignore_permissions=True)
    
    return {
        "success": True,
        "file_url": file_doc.file_url,
        "file_name": file_doc.file_name,
        "file_size": file_doc.file_size
    }

def validate_file_upload(file_data, filename):
    """Validate uploaded file"""
    
    # Check file size (10MB limit)
    max_size = 10 * 1024 * 1024
    if len(file_data) > max_size:
        frappe.throw(_("File size cannot exceed 10MB"))
    
    # Check file extension
    allowed_extensions = get_allowed_extensions()
    file_ext = os.path.splitext(filename)[1].lower()
    
    if file_ext not in allowed_extensions:
        frappe.throw(_("File type {0} not allowed").format(file_ext))
    
    # Check MIME type
    mime_type = mimetypes.guess_type(filename)[0]
    if mime_type and not is_safe_mime_type(mime_type):
        frappe.throw(_("Unsafe file type detected"))
    
    # Scan for malicious content
    if contains_malicious_content(file_data, filename):
        frappe.throw(_("File contains potentially malicious content"))

def get_allowed_extensions():
    """Get allowed file extensions from settings"""
    return frappe.get_single("File Manager Settings").allowed_file_extensions.split(",") or [
        ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
        ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg",
        ".txt", ".csv", ".json", ".xml", ".zip", ".rar"
    ]

def is_safe_mime_type(mime_type):
    """Check if MIME type is safe"""
    dangerous_types = [
        "application/x-executable",
        "application/x-msdownload",
        "application/x-msdos-program",
        "text/x-script",
        "application/javascript",
        "text/html"
    ]
    return mime_type not in dangerous_types

def contains_malicious_content(file_data, filename):
    """Basic malware detection"""
    
    # Check for suspicious file signatures
    suspicious_signatures = [
        b"MZ",  # PE executable
        b"\x7fELF",  # ELF executable
        b"<script",  # JavaScript in uploads
        b"javascript:",  # JavaScript protocol
        b"data:text/html"  # Data URI with HTML
    ]
    
    file_start = file_data[:1024].lower()
    return any(sig in file_start for sig in suspicious_signatures)
```

### Advanced File Upload with Processing:

```python
# [app]/api/advanced_upload.py

import frappe
from frappe.utils.background_jobs import enqueue
from PIL import Image
import io
import base64

@frappe.whitelist()
def upload_and_process_image(doctype, docname, image_data, filename):
    """Upload and process image with thumbnails"""
    
    # Validate permissions
    if not frappe.has_permission(doctype, "write", docname):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    
    # Decode base64 image
    try:
        image_content = base64.b64decode(image_data.split(',')[1])
    except:
        frappe.throw(_("Invalid image data"))
    
    # Validate image
    validate_image(image_content, filename)
    
    # Process in background for large images
    if len(image_content) > 2 * 1024 * 1024:  # 2MB
        enqueue(
            process_large_image,
            queue='default',
            timeout=300,
            doctype=doctype,
            docname=docname,
            image_content=image_content,
            filename=filename
        )
        return {"success": True, "message": "Image upload queued for processing"}
    
    else:
        return process_image_sync(doctype, docname, image_content, filename)

def validate_image(image_content, filename):
    """Validate uploaded image"""
    
    try:
        img = Image.open(io.BytesIO(image_content))
        
        # Check image format
        if img.format not in ['JPEG', 'PNG', 'GIF', 'BMP', 'WEBP']:
            frappe.throw(_("Unsupported image format"))
        
        # Check image dimensions
        if img.width > 4000 or img.height > 4000:
            frappe.throw(_("Image dimensions too large (max 4000x4000)"))
        
        # Check for suspicious EXIF data
        if hasattr(img, '_getexif') and img._getexif():
            exif = img._getexif()
            if exif and any(tag in str(exif) for tag in ['<script', 'javascript', 'data:']):
                frappe.throw(_("Suspicious image content detected"))
                
    except Exception as e:
        frappe.throw(_("Invalid image file: {0}").format(str(e)))

def process_image_sync(doctype, docname, image_content, filename):
    """Process image synchronously"""
    
    # Create original file
    original_file = save_file(
        fname=filename,
        content=image_content,
        dt=doctype,
        dn=docname,
        is_private=0
    )
    
    # Create thumbnails
    thumbnails = create_thumbnails(image_content, filename)
    
    # Attach thumbnails
    for size, thumb_content in thumbnails.items():
        thumb_filename = f"thumb_{size}_{filename}"
        save_file(
            fname=thumb_filename,
            content=thumb_content,
            dt=doctype,
            dn=docname,
            is_private=0
        )
    
    return {
        "success": True,
        "original_file": original_file.file_url,
        "thumbnails": {size: f"/files/thumb_{size}_{filename}" for size in thumbnails.keys()}
    }

def create_thumbnails(image_content, filename):
    """Create image thumbnails"""
    
    img = Image.open(io.BytesIO(image_content))
    thumbnails = {}
    
    sizes = {
        "small": (150, 150),
        "medium": (300, 300),
        "large": (600, 600)
    }
    
    for size_name, (width, height) in sizes.items():
        # Create thumbnail
        thumb = img.copy()
        thumb.thumbnail((width, height), Image.Resampling.LANCZOS)
        
        # Save to bytes
        thumb_io = io.BytesIO()
        thumb.save(thumb_io, format=img.format, quality=85, optimize=True)
        thumbnails[size_name] = thumb_io.getvalue()
    
    return thumbnails

def process_large_image(doctype, docname, image_content, filename):
    """Background processing for large images"""
    
    try:
        # Process image
        result = process_image_sync(doctype, docname, image_content, filename)
        
        # Notify user
        frappe.publish_realtime(
            event="image_processed",
            message=result,
            user=frappe.session.user
        )
        
    except Exception as e:
        # Notify user of error
        frappe.publish_realtime(
            event="image_processing_error",
            message={"error": str(e)},
            user=frappe.session.user
        )
```

---

## 🔴 FILE DOWNLOAD PATTERNS

### Secure File Download:

```python
# [app]/api/file_download.py

import frappe
from frappe import _
from frappe.utils import get_files_path
import os
import mimetypes

@frappe.whitelist()
def download_file(file_name, doctype=None, docname=None):
    """Secure file download with permission checking"""
    
    # Get file document
    file_doc = frappe.get_doc("File", {"file_name": file_name})
    
    # Check permissions
    if not can_access_file(file_doc, doctype, docname):
        frappe.throw(_("Access denied"), frappe.PermissionError)
    
    # Get file path
    file_path = get_file_path(file_doc)
    
    if not os.path.exists(file_path):
        frappe.throw(_("File not found"))
    
    # Log file access
    log_file_access(file_doc, "download")
    
    # Stream file
    return stream_file(file_path, file_doc.file_name)

def can_access_file(file_doc, doctype=None, docname=None):
    """Check if user can access file"""
    
    # Public files are accessible to all
    if not file_doc.is_private:
        return True
    
    # Check if file is attached to document
    if file_doc.attached_to_doctype and file_doc.attached_to_name:
        return frappe.has_permission(
            file_doc.attached_to_doctype, 
            "read", 
            file_doc.attached_to_name
        )
    
    # Check against specific document if provided
    if doctype and docname:
        return frappe.has_permission(doctype, "read", docname)
    
    # Default deny for private files
    return False

def get_file_path(file_doc):
    """Get physical file path"""
    
    if file_doc.is_private:
        return os.path.join(get_files_path(), "private", file_doc.file_name)
    else:
        return os.path.join(get_files_path(), file_doc.file_name)

def stream_file(file_path, filename):
    """Stream file to browser"""
    
    # Get MIME type
    mime_type = mimetypes.guess_type(filename)[0] or 'application/octet-stream'
    
    # Set response headers
    frappe.local.response.filename = filename
    frappe.local.response.filecontent = open(file_path, 'rb').read()
    frappe.local.response.type = 'binary'
    frappe.local.response.headers['Content-Type'] = mime_type
    frappe.local.response.headers['Content-Disposition'] = f'attachment; filename="{filename}"'

def log_file_access(file_doc, action):
    """Log file access for audit"""
    
    frappe.get_doc({
        "doctype": "Activity Log",
        "subject": f"File {action}: {file_doc.file_name}",
        "content": f"User {frappe.session.user} performed {action} on {file_doc.file_name}",
        "reference_doctype": "File",
        "reference_name": file_doc.name
    }).insert(ignore_permissions=True)
```

### Bulk File Operations:

```python
# [app]/api/bulk_files.py

import frappe
from frappe.utils.background_jobs import enqueue
import zipfile
import io

@frappe.whitelist()
def download_multiple_files(file_names, doctype=None, docname=None):
    """Download multiple files as ZIP"""
    
    # Validate file access
    accessible_files = []
    for file_name in file_names:
        try:
            file_doc = frappe.get_doc("File", {"file_name": file_name})
            if can_access_file(file_doc, doctype, docname):
                accessible_files.append(file_doc)
        except:
            continue
    
    if not accessible_files:
        frappe.throw(_("No accessible files found"))
    
    # Create ZIP in background if many files
    if len(accessible_files) > 10:
        enqueue(
            create_zip_archive,
            queue='long',
            timeout=600,
            files=accessible_files,
            user=frappe.session.user
        )
        return {"success": True, "message": "ZIP creation queued"}
    
    else:
        return create_zip_sync(accessible_files)

def create_zip_sync(files):
    """Create ZIP archive synchronously"""
    
    zip_buffer = io.BytesIO()
    
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for file_doc in files:
            file_path = get_file_path(file_doc)
            if os.path.exists(file_path):
                zip_file.write(file_path, file_doc.file_name)
    
    zip_content = zip_buffer.getvalue()
    zip_filename = f"files_{frappe.utils.nowdate()}.zip"
    
    # Save ZIP as temporary file
    zip_file_doc = save_file(
        fname=zip_filename,
        content=zip_content,
        is_private=1
    )
    
    return {
        "success": True,
        "zip_file": zip_file_doc.file_url,
        "file_count": len(files)
    }

def create_zip_archive(files, user):
    """Background ZIP creation"""
    
    try:
        result = create_zip_sync(files)
        
        # Notify user
        frappe.publish_realtime(
            event="zip_ready",
            message=result,
            user=user
        )
        
        # Send email with download link
        frappe.sendmail(
            recipients=[user],
            subject="File Archive Ready",
            message=f"""
            <p>Your file archive is ready for download.</p>
            <p><a href="{result['zip_file']}">Download ZIP ({result['file_count']} files)</a></p>
            """
        )
        
    except Exception as e:
        frappe.publish_realtime(
            event="zip_error",
            message={"error": str(e)},
            user=user
        )

@frappe.whitelist()
def delete_multiple_files(file_names, doctype=None, docname=None):
    """Delete multiple files"""
    
    deleted_count = 0
    errors = []
    
    for file_name in file_names:
        try:
            file_doc = frappe.get_doc("File", {"file_name": file_name})
            
            # Check permissions
            if not can_delete_file(file_doc, doctype, docname):
                errors.append(f"No permission to delete {file_name}")
                continue
            
            # Delete file
            file_doc.delete()
            deleted_count += 1
            
        except Exception as e:
            errors.append(f"Error deleting {file_name}: {str(e)}")
    
    return {
        "success": True,
        "deleted_count": deleted_count,
        "errors": errors
    }

def can_delete_file(file_doc, doctype=None, docname=None):
    """Check if user can delete file"""
    
    # Check if file is attached to document
    if file_doc.attached_to_doctype and file_doc.attached_to_name:
        return frappe.has_permission(
            file_doc.attached_to_doctype,
            "delete",
            file_doc.attached_to_name
        )
    
    # Check against specific document if provided
    if doctype and docname:
        return frappe.has_permission(doctype, "delete", docname)
    
    # Only system manager can delete unattached files
    return frappe.has_role("System Manager")
```

---

## 🔴 FILE STORAGE OPTIMIZATION

### File Compression and Optimization:

```python
# [app]/utils/file_optimization.py

import frappe
from PIL import Image
import io
import gzip
import json

def optimize_file_on_upload(file_doc, method):
    """Optimize files after upload"""
    
    file_path = get_file_path(file_doc)
    
    # Optimize based on file type
    if file_doc.file_name.lower().endswith(('.jpg', '.jpeg', '.png')):
        optimize_image(file_path, file_doc)
    
    elif file_doc.file_name.lower().endswith(('.json', '.txt', '.csv')):
        compress_text_file(file_path, file_doc)
    
    elif file_doc.file_name.lower().endswith('.pdf'):
        optimize_pdf(file_path, file_doc)

def optimize_image(file_path, file_doc):
    """Optimize image files"""
    
    try:
        with Image.open(file_path) as img:
            # Convert to RGB if necessary
            if img.mode in ('RGBA', 'LA', 'P'):
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                rgb_img.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = rgb_img
            
            # Resize if too large
            max_dimension = 1920
            if img.width > max_dimension or img.height > max_dimension:
                img.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
            
            # Save optimized version
            optimized_path = file_path + ".optimized"
            img.save(optimized_path, format='JPEG', quality=85, optimize=True)
            
            # Replace original if smaller
            if os.path.getsize(optimized_path) < os.path.getsize(file_path):
                os.replace(optimized_path, file_path)
                
                # Update file size
                new_size = os.path.getsize(file_path)
                file_doc.db_set("file_size", new_size)
            else:
                os.remove(optimized_path)
                
    except Exception as e:
        frappe.log_error(f"Image optimization failed: {str(e)}")

def compress_text_file(file_path, file_doc):
    """Compress text files"""
    
    try:
        with open(file_path, 'rb') as f:
            content = f.read()
        
        # Compress content
        compressed = gzip.compress(content)
        
        # Save if compression is beneficial (>20% reduction)
        if len(compressed) < len(content) * 0.8:
            compressed_path = file_path + ".gz"
            with open(compressed_path, 'wb') as f:
                f.write(compressed)
            
            os.replace(compressed_path, file_path)
            
            # Update file info
            file_doc.db_set("file_size", len(compressed))
            file_doc.db_set("is_compressed", 1)
            
    except Exception as e:
        frappe.log_error(f"Text compression failed: {str(e)}")

def optimize_pdf(file_path, file_doc):
    """Optimize PDF files"""
    
    try:
        import PyPDF2
        
        # Only attempt optimization for large PDFs
        if os.path.getsize(file_path) > 5 * 1024 * 1024:  # 5MB
            
            # Enqueue for background processing
            enqueue(
                optimize_pdf_background,
                queue='long',
                timeout=1800,
                file_path=file_path,
                file_doc_name=file_doc.name
            )
            
    except ImportError:
        pass  # PyPDF2 not available
    except Exception as e:
        frappe.log_error(f"PDF optimization failed: {str(e)}")

def optimize_pdf_background(file_path, file_doc_name):
    """Background PDF optimization"""
    
    try:
        import PyPDF2
        
        with open(file_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            writer = PyPDF2.PdfWriter()
            
            for page in reader.pages:
                page.compress_content_streams()
                writer.add_page(page)
            
            optimized_path = file_path + ".optimized"
            with open(optimized_path, 'wb') as output_file:
                writer.write(output_file)
        
        # Replace if smaller
        if os.path.getsize(optimized_path) < os.path.getsize(file_path):
            os.replace(optimized_path, file_path)
            
            # Update file size
            file_doc = frappe.get_doc("File", file_doc_name)
            new_size = os.path.getsize(file_path)
            file_doc.db_set("file_size", new_size)
        else:
            os.remove(optimized_path)
            
    except Exception as e:
        frappe.log_error(f"Background PDF optimization failed: {str(e)}")
```

---

## 🔴 FILE CLEANUP AND MAINTENANCE

### Automated File Cleanup:

```python
# [app]/utils/file_cleanup.py

import frappe
from frappe.utils import add_days, today
import os

def cleanup_orphaned_files():
    """Remove files not attached to any document"""
    
    # Get all files
    all_files = frappe.get_all("File", fields=["name", "file_name", "attached_to_doctype", "attached_to_name"])
    
    orphaned_files = []
    for file_doc in all_files:
        if not file_doc.attached_to_doctype:
            orphaned_files.append(file_doc)
        elif not frappe.db.exists(file_doc.attached_to_doctype, file_doc.attached_to_name):
            orphaned_files.append(file_doc)
    
    # Remove orphaned files older than 30 days
    cutoff_date = add_days(today(), -30)
    
    for file_info in orphaned_files:
        file_doc = frappe.get_doc("File", file_info.name)
        if file_doc.creation.date() < cutoff_date:
            try:
                file_doc.delete()
                frappe.log_error(f"Removed orphaned file: {file_info.file_name}", "File Cleanup")
            except Exception as e:
                frappe.log_error(f"Failed to remove orphaned file {file_info.file_name}: {str(e)}")

def cleanup_temp_files():
    """Remove temporary files"""
    
    temp_dir = os.path.join(frappe.get_site_path(), "private", "files", "temp")
    
    if os.path.exists(temp_dir):
        cutoff_time = time.time() - (24 * 60 * 60)  # 24 hours ago
        
        for filename in os.listdir(temp_dir):
            file_path = os.path.join(temp_dir, filename)
            if os.path.getmtime(file_path) < cutoff_time:
                try:
                    os.remove(file_path)
                except Exception as e:
                    frappe.log_error(f"Failed to remove temp file {filename}: {str(e)}")

def analyze_storage_usage():
    """Analyze file storage usage"""
    
    storage_stats = {
        "total_files": 0,
        "total_size": 0,
        "private_files": 0,
        "private_size": 0,
        "public_files": 0,
        "public_size": 0,
        "by_doctype": {}
    }
    
    files = frappe.get_all("File", fields=["file_size", "is_private", "attached_to_doctype"])
    
    for file_info in files:
        size = file_info.file_size or 0
        
        storage_stats["total_files"] += 1
        storage_stats["total_size"] += size
        
        if file_info.is_private:
            storage_stats["private_files"] += 1
            storage_stats["private_size"] += size
        else:
            storage_stats["public_files"] += 1
            storage_stats["public_size"] += size
        
        # Group by DocType
        doctype = file_info.attached_to_doctype or "Unattached"
        if doctype not in storage_stats["by_doctype"]:
            storage_stats["by_doctype"][doctype] = {"count": 0, "size": 0}
        
        storage_stats["by_doctype"][doctype]["count"] += 1
        storage_stats["by_doctype"][doctype]["size"] += size
    
    return storage_stats

# Scheduler Events (add to hooks.py)
scheduler_events = {
    "daily": [
        "app_name.utils.file_cleanup.cleanup_temp_files"
    ],
    "weekly": [
        "app_name.utils.file_cleanup.cleanup_orphaned_files"
    ]
}
```

---

## 📋 FILE MANAGEMENT CHECKLIST

Before deploying file features:

- [ ] Configure file size limits
- [ ] Set up allowed file types
- [ ] Implement virus scanning
- [ ] Add proper permission checks
- [ ] Test upload/download flows
- [ ] Configure file optimization
- [ ] Set up backup procedures
- [ ] Add audit logging
- [ ] Test bulk operations
- [ ] Implement cleanup routines
- [ ] Monitor storage usage
- [ ] Add error handling

---

**REMEMBER**: File security is critical - always validate, scan, and control access to uploaded files!