import os
import re

BLOG_DIR = "/app/new-website/src/content/blog/"

def fix_blog_post(filepath):
    """
    Fixes the frontmatter and renames a blog post.
    """
    try:
        with open(filepath, 'r') as f:
            content = f.read()

        # Extract frontmatter and body
        match = re.match(r'---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
        if not match:
            print(f"Could not parse frontmatter for {filepath}")
            return

        frontmatter_str, body = match.groups()

        # Parse frontmatter
        data = {}
        for line in frontmatter_str.strip().split('\n'):
            parts = line.split(':', 1)
            if len(parts) == 2:
                key, value = parts
                data[key.strip()] = value.strip()

        # Fix date (remove quotes)
        if 'date' in data:
            date_val = data['date'].strip('"\'') # remove existing quotes
            if ' ' in date_val:
                data['date'] = date_val.split(" ")[0]
            else:
                data['date'] = date_val


        # Fix tags
        if 'tags' in data and not data['tags'].startswith('['):
            tags = [f'"{tag.strip()}"' for tag in data['tags'].split(',')]
            data['tags'] = f"[{', '.join(tags)}]"

        # Rebuild frontmatter
        new_frontmatter_lines = [f"{key}: {value}" for key, value in data.items()]
        new_frontmatter = '\n'.join(new_frontmatter_lines)

        new_content = f'---\n{new_frontmatter}\n---\n\n{body.strip()}'

        # Rename file
        new_filename = os.path.basename(filepath)
        if not new_filename.endswith('.md'):
            new_filename = new_filename.replace('.html.markdown', '.md')
            new_filename = new_filename.replace('.markdown', '.md')
            new_filename = new_filename.replace('.html.md.erb', '.md')
            new_filename = new_filename.replace('.html.md', '.md')

        new_filepath = os.path.join(BLOG_DIR, new_filename)

        with open(new_filepath, 'w') as f:
            f.write(new_content)

        if filepath != new_filepath and os.path.exists(filepath):
             os.remove(filepath)

        print(f"Processed {filepath} -> {new_filepath}")

    except Exception as e:
        print(f"Error processing {filepath}: {e}")


if __name__ == "__main__":
    # Get a list of files to process before iterating
    files_to_process = [os.path.join(BLOG_DIR, f) for f in os.listdir(BLOG_DIR) if os.path.isfile(os.path.join(BLOG_DIR, f))]
    for filepath in files_to_process:
        fix_blog_post(filepath)