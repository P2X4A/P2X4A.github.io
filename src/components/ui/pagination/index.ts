import Pagination, { pagination } from "./Pagination.astro";
import PaginationEllipsis, { paginationEllipsis } from "./PaginationEllipsis.astro";
import PaginationItem, { paginationItem } from "./PaginationItem.astro";
import PaginationLink from "./PaginationLink.astro";

const PaginationVariants = { pagination, paginationItem, paginationEllipsis };

export { Pagination, PaginationEllipsis, PaginationItem, PaginationLink, PaginationVariants };
export default Pagination;
