import os
import shutil
import subprocess
from argparse import ArgumentParser, Namespace
from concurrent.futures import ProcessPoolExecutor, as_completed
from tqdm import tqdm

def parse_arguments() -> Namespace:
    parser = ArgumentParser(
        prog='MacOS Folder Icon Generation',
        description='This script generates icons for MacOS directories merged with an .svg icon.'
    )
    parser.add_argument("-s", "--source-dir", required=True, type=str, help='Directory containing the .svg icons.')
    parser.add_argument("-t", "--target-dir", type=str, default=".", help='Directory where the icons sets will be saved.')
    parser.add_argument("-w", "--workers", type=int, default=3, help='Number of workers for processing the icons.')
    return parser.parse_args()

def process_icon(icon_info):
    dirpath, icon, target_dir = icon_info
    icon_svg_path = os.path.join(dirpath, icon)
    icon_name = os.path.splitext(icon)[0]
    iconset_path = os.path.join(target_dir, icon_name)
    iconset_svg_path = os.path.join(iconset_path, icon)

    if not os.path.exists(iconset_path):
        os.makedirs(iconset_path, exist_ok=True)
        shutil.copy(icon_svg_path, iconset_svg_path)
        subprocess.run([
            "folderify",
            "--output-icns", f"{iconset_path}/{icon_name}.icns",
            "--output-iconset", f"{iconset_path}/{icon_name}.iconset",
            "--no-progress", "--verbose",
            iconset_svg_path, iconset_path
        ], capture_output=True, text=True)
        return icon_name

def generate_icons(source_dir: str, target_dir: str, workers: int) -> None:
    icons_info = [(dirpath, filename, target_dir)
                  for dirpath, dirnames, filenames in os.walk(source_dir)
                  for filename in filenames if filename.endswith('.svg')]

    total_icons = len(icons_info)
    if total_icons == 0:
        print("No SVG files found in the source directory.")
        return

    with ProcessPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(process_icon, icon_info) for icon_info in icons_info]
        for _ in tqdm(as_completed(futures), total=total_icons, desc="Generating Icons"):
            pass


if __name__ == '__main__':
    args = parse_arguments()
    print("Start generating icon sets.")
    print(f"Processing icons from: {args.source_dir}")
    generate_icons(args.source_dir, args.target_dir, args.workers)
    print("Successfully processed all icons.")
