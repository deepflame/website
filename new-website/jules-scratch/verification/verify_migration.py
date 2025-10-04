from playwright.sync_api import sync_playwright

def run(playwright):
    browser = playwright.chromium.launch()
    page = browser.new_page()

    # Home page
    page.goto("http://localhost:4321")
    page.screenshot(path="/app/new-website/jules-scratch/verification/homepage.png")

    # Blog index
    page.goto("http://localhost:4321/blog")
    page.screenshot(path="/app/new-website/jules-scratch/verification/blog-index.png")

    # A specific blog post
    page.goto("http://localhost:4321/blog/2014-02-02-testing-multiple-ios-platforms-on-travis")
    page.screenshot(path="/app/new-website/jules-scratch/verification/blog-post.png")

    browser.close()

with sync_playwright() as playwright:
    run(playwright)