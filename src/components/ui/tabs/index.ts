import Tabs, { tabs } from "./Tabs.astro";
import TabsContent, { tabsContent } from "./TabsContent.astro";
import TabsList, { tabsList } from "./TabsList.astro";
import TabsTrigger, { tabsTrigger } from "./TabsTrigger.astro";

const TabsVariants = { tabs, tabsList, tabsTrigger, tabsContent };

export { Tabs, TabsContent, TabsList, TabsTrigger, TabsVariants };
export default Tabs;
