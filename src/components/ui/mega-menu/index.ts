import MegaMenu, { megaMenu } from "./MegaMenu.astro";
import MegaMenuItem, { megaMenuItem } from "./MegaMenuItem.astro";
import MegaMenuPanel, { megaMenuPanel } from "./MegaMenuPanel.astro";
import MegaMenuTrigger from "./MegaMenuTrigger.astro";

const MegaMenuVariants = { megaMenu, megaMenuPanel, megaMenuItem };

export { MegaMenu, MegaMenuItem, MegaMenuPanel, MegaMenuTrigger, MegaMenuVariants };
export default MegaMenu;
