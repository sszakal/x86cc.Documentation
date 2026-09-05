import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docs: [
    'intro',
    {
      type: 'category',
      label: 'Requirements',
      items: ['requirements/overview'],
    },
    {
      type: 'category',
      label: 'Architecture',
      items: ['architecture/overview', 'architecture/tech-stack', 'architecture/backend', 'architecture/frontend'],
    },
    {
      type: 'category',
      label: 'ADRs',
      items: ['adr/wolverinefx-http-and-messaging', 'adr/event-sourcing-with-marten'],
    },
    {
      type: 'category',
      label: 'Operations',
      items: ['operations/ci-cd'],
    },
  ],
};

export default sidebars;
