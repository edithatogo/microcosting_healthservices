import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import starlightVersions from 'starlight-versions';

export default defineConfig({
  site: 'https://edithatogo.github.io/microcosting_healthservices/',
  base: '/microcosting_healthservices/',
  integrations: [
    starlightLinksValidator(),
    starlight({
      title: 'Microcosting Health Services',
      logo: {
        src: './src/assets/logo.svg',
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/edithatogo/microcosting_healthservices',
        },
      ],
      editLink: {
        baseUrl:
          'https://github.com/edithatogo/microcosting_healthservices/edit/master/docs-site/',
      },
      sidebar: [
        {
          label: 'Overview',
          items: ['index', 'migration/legacy-docs'],
        },
      ],
      plugins: [
        starlightVersions({
          versions: [
            {
              slug: '2025',
              label: '2025',
            },
          ],
        }),
      ],
    }),
  ],
});
