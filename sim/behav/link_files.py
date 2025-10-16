#!/usr/bin/env python3
"""
Link Files Script for RISC-V DSP Processor
Creates symbolic links for Cadence simulation environment
"""

import os
import sys
import argparse
import glob

def create_symlinks(include_file, workspace_dir):
    """Create symbolic links based on include file"""
    
    # Create sym_links directory
    sym_links_dir = os.path.join(workspace_dir, "sym_links")
    os.makedirs(sym_links_dir, exist_ok=True)
    
    # Read include file
    include_path = os.path.join("Include", include_file)
    if not os.path.exists(include_path):
        print(f"Error: Include file {include_path} not found")
        return False
    
    with open(include_path, 'r') as f:
        lines = f.readlines()
    
    # Process each line
    for line in lines:
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
        
        # Handle relative paths
        if line.startswith('../../'):
            source_path = line
        else:
            source_path = f"../../{line}"
        
        # Create destination path
        filename = os.path.basename(line)
        dest_path = os.path.join(sym_links_dir, filename)
        
        # Create symbolic link
        try:
            if os.path.exists(dest_path):
                os.remove(dest_path)
            
            # Use absolute path for source
            abs_source = os.path.abspath(source_path)
            if os.path.exists(abs_source):
                os.symlink(abs_source, dest_path)
                print(f"Linked: {filename}")
            else:
                print(f"Warning: Source file {abs_source} not found")
        except Exception as e:
            print(f"Error linking {filename}: {e}")
    
    # Create sim_no_path.include file
    sim_include_path = os.path.join(sym_links_dir, "sim_no_path.include")
    with open(sim_include_path, 'w') as f:
        for line in lines:
            line = line.strip()
            if line and not line.startswith('#'):
                filename = os.path.basename(line)
                # Write full path to sym_links directory
                f.write(f"sym_links/{filename}\n")
    
    print(f"Created {sim_include_path}")
    return True

def main():
    parser = argparse.ArgumentParser(description='Create symbolic links for simulation')
    parser.add_argument('include_file', help='Include file name')
    parser.add_argument('--workspace', default='WORKSPACE', help='Workspace directory')
    
    args = parser.parse_args()
    
    # Get current directory
    current_dir = os.getcwd()
    workspace_dir = os.path.join(current_dir, args.workspace)
    
    print(f"Creating symbolic links in {workspace_dir}")
    print(f"Using include file: {args.include_file}")
    
    success = create_symlinks(args.include_file, workspace_dir)
    
    if success:
        print("Symbolic links created successfully")
    else:
        print("Failed to create symbolic links")
        sys.exit(1)

if __name__ == "__main__":
    main()
