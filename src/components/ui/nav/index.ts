import Nav, { nav } from "./Nav.astro";
import NavItem, { navItem } from "./NavItem.astro";
import NavLink, { navLink } from "./NavLink.astro";

const NavVariants = {
  nav,
  navItem,
  navLink,
};

export { Nav, NavItem, NavLink, NavVariants };
export default Nav;
