import Breadcrumb, { breadcrumb } from "./Breadcrumb.astro";
import BreadcrumbItem, { breadcrumbItem } from "./BreadcrumbItem.astro";
import BreadcrumbLink, { breadcrumbLink } from "./BreadcrumbLink.astro";
import BreadcrumbPage, { breadcrumbPage } from "./BreadcrumbPage.astro";
import BreadcrumbSeparator, { breadcrumbSeparator } from "./BreadcrumbSeparator.astro";

const BreadcrumbVariants = {
  breadcrumb,
  breadcrumbItem,
  breadcrumbLink,
  breadcrumbPage,
  breadcrumbSeparator,
};

export {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbPage,
  BreadcrumbSeparator,
  BreadcrumbVariants,
};
export default Breadcrumb;
