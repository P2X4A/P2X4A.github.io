import Dropdown, { dropdown } from "./Dropdown.astro";
import DropdownItem, { dropdownItem } from "./DropdownItem.astro";
import DropdownMenu, { dropdownMenu } from "./DropdownMenu.astro";
import DropdownTrigger from "./DropdownTrigger.astro";

const DropdownVariants = { dropdown, dropdownMenu, dropdownItem };

export { Dropdown, DropdownItem, DropdownMenu, DropdownTrigger, DropdownVariants };
export default Dropdown;
