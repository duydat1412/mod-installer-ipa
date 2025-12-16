#!/usr/bin/env python3
"""
Generate app icons for iOS using ImageMagick or PIL
Run: python generate_icons.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, filename):
    """Create a simple cube icon"""
    img = Image.new('RGB', (size, size), color='#007AFF')
    draw = ImageDraw.Draw(img)
    
    # Draw a simple cube shape
    margin = size // 4
    w = size - 2 * margin
    h = size - 2 * margin
    
    # Front face (blue)
    points = [
        (margin, margin + h//3),
        (margin + w//2, margin),
        (margin + w, margin + h//3),
        (margin + w//2, margin + 2*h//3)
    ]
    draw.polygon(points, fill='#0051D5')
    
    # Left face (darker blue)
    points = [
        (margin, margin + h//3),
        (margin + w//2, margin + 2*h//3),
        (margin + w//2, margin + h),
        (margin, margin + 2*h//3)
    ]
    draw.polygon(points, fill='#003D99')
    
    # Right face (lighter blue)
    points = [
        (margin + w//2, margin + 2*h//3),
        (margin + w, margin + h//3),
        (margin + w, margin + 2*h//3),
        (margin + w//2, margin + h)
    ]
    draw.polygon(points, fill='#0066FF')
    
    # Save with proper path
    output_path = os.path.join('ModInstaller', 'Assets.xcassets', 'AppIcon.appiconset', filename)
    img.save(output_path, 'PNG')
    print(f'Created {filename} ({size}x{size})')

if __name__ == '__main__':
    sizes = {
        'icon_20pt@2x.png': 40,
        'icon_20pt@3x.png': 60,
        'icon_29pt@2x.png': 58,
        'icon_29pt@3x.png': 87,
        'icon_40pt@2x.png': 80,
        'icon_40pt@3x.png': 120,
        'icon_60pt@2x.png': 120,
        'icon_60pt@3x.png': 180,
        'icon_1024.png': 1024,
    }
    
    for filename, size in sizes.items():
        create_icon(size, filename)
    
    print('\n✅ All icons generated successfully!')
    print('Icons are in ModInstaller/Assets.xcassets/AppIcon.appiconset/')
