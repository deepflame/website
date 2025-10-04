import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const blog = await getCollection('blog');
  return rss({
    title: 'Andreas Böhrnsen',
    description: 'Consultant & Developer',
    site: 'http://andreas.boehrnsen.de',
    items: blog.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.body.split('READMORE')[0],
      link: `/blog/${post.slug}/`,
    })),
    customData: `<language>en-us</language>`,
  });
}