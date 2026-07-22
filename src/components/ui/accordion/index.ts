import Accordion, { accordion } from "./Accordion.astro";
import AccordionContent, { accordionContent } from "./AccordionContent.astro";
import AccordionItem, { accordionItem } from "./AccordionItem.astro";
import AccordionTrigger, { accordionTrigger } from "./AccordionTrigger.astro";

const AccordionVariants = { accordion, accordionItem, accordionTrigger, accordionContent };

export { Accordion, AccordionContent, AccordionItem, AccordionTrigger, AccordionVariants };
export default Accordion;
