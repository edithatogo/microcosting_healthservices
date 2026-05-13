import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import starlightVersions from 'starlight-versions';

const repository = process.env.GITHUB_REPOSITORY ?? 'edithatogo/microcosting_healthservices';
const [owner, repo] = repository.split('/');
const siteUrl =
  process.env.SITE_URL ?? `https://${owner}.github.io/${repo}/`;
const siteBase = process.env.SITE_BASE ?? `/${repo}/`;

export default defineConfig({
  site: siteUrl,
  base: siteBase,
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
          items: ['index', 'versions', 'versions/2025', 'migration/legacy-docs'],
        },
        {
          label: 'Tutorials',
          items: [
            {
              label: 'Costing Studies',
              items: [
                'tutorials/costing-study-nwau-nep',
                'tutorials/costing-study-cost-vs-price',
                'tutorials/costing-study-stream-benchmarking',
              ],
            },
          ],
        },
        {
          label: 'Coverage',
          items: [
            'governance/calculator-coverage',
            'governance/public-calculator-contract',
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
            'governance/polyglot-rust-core-roadmap',
            'governance/reference-generation',
            'governance/public-readiness',
            'governance/streamlit-delivery',
            'governance/downstream-packaging-plans',
            'governance/go-binding',
            'governance/java-jvm-binding',
            'governance/csharp-dotnet-binding',
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
