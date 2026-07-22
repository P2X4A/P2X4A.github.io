import Icon, { icon } from "./Icon.astro";
import { type IconName, iconNames } from "./icons";

const IconVariants = { icon };

export { Icon, iconNames, IconVariants };
export type { IconName };
export default Icon;
