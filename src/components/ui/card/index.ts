import Card, { card } from "./Card.astro";
import CardAction, { cardAction } from "./CardAction.astro";
import CardContent, { cardContent } from "./CardContent.astro";
import CardDescription, { cardDescription } from "./CardDescription.astro";
import CardFooter, { cardFooter } from "./CardFooter.astro";
import CardHeader, { cardHeader } from "./CardHeader.astro";
import CardImage, { cardImage } from "./CardImage.astro";
import CardTitle, { cardTitle } from "./CardTitle.astro";

const CardVariants = {
  card,
  cardImage,
  cardHeader,
  cardTitle,
  cardDescription,
  cardAction,
  cardContent,
  cardFooter,
};

export {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardImage,
  CardTitle,
  CardVariants,
};
export default Card;
