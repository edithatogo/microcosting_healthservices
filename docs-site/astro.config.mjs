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
      description:
        'Versioned IHACPA calculator docs, archive coverage, and delivery guidance.',
      logo: {
        src: './src/assets/logo.svg',
      },
      customCss: ['./src/styles/custom.css'],
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
          items: ['index', 'versions/2025', 'migration/legacy-docs'],
        },
        {
          label: 'Coverage',
          items: [
            'governance/calculator-coverage',
            'governance/source-archive',
          ],
        },
        {
          label: 'Governance',
          items: [
            'governance/product',
            'governance/tech-stack',
            'governance/workflow',
            'governance/validation-vocabulary',
            'governance/data-governance',
            'governance/rust-core-architecture',
            'governance/reference-generation',
            'governance/public-readiness',
            'governance/streamlit-delivery',
            'governance/downstream-packaging-plans',
            'governance/web-and-power-platform-delivery',
            'governance/release-policy',
            'governance/supply-chain-controls',
          ],
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
