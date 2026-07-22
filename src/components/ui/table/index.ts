import Table, { table } from "./Table.astro";
import TableBody, { tableBody } from "./TableBody.astro";
import TableCaption, { tableCaption } from "./TableCaption.astro";
import TableCell, { tableCell } from "./TableCell.astro";
import TableFooter, { tableFooter } from "./TableFooter.astro";
import TableHead, { tableHead } from "./TableHead.astro";
import TableHeader, { tableHeader } from "./TableHeader.astro";
import TableRow, { tableRow } from "./TableRow.astro";

const TableVariants = {
  table,
  tableHeader,
  tableBody,
  tableFooter,
  tableRow,
  tableHead,
  tableCell,
  tableCaption,
};

export {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
  TableVariants,
};
export default Table;
