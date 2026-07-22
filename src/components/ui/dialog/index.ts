import Dialog, { dialog } from "./Dialog.astro";
import DialogClose from "./DialogClose.astro";
import DialogDescription, { dialogDescription } from "./DialogDescription.astro";
import DialogFooter, { dialogFooter } from "./DialogFooter.astro";
import DialogHeader, { dialogHeader } from "./DialogHeader.astro";
import DialogTitle, { dialogTitle } from "./DialogTitle.astro";
import DialogTrigger from "./DialogTrigger.astro";

const DialogVariants = { dialog, dialogHeader, dialogFooter, dialogTitle, dialogDescription };

export {
  Dialog,
  DialogClose,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogVariants,
};
export default Dialog;
