import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const blog = await getCollection('blog');
  const sortedPosts = blog.sort(
    (a, b) => b.data.date.valueOf() - a.data.date.valueOf()
  );
  
  return rss({
    title: 'Andreas Böhrnsen',
    description: 'Consultant & Developer',
    site: context.site,
    items: sortedPosts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.description || post.body.split('READMORE')[0].trim(),
      link: `/blog/${post.slug}/`,
    })),
    customData: `<language>en-us</language>`,
  });
}