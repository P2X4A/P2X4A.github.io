import PasswordInput from "./PasswordInput.astro";
import PasswordStrength, { passwordStrength } from "./PasswordStrength.astro";

const PasswordVariants = { passwordStrength };

export { scorePassword, type Strength } from "./strength";
export { PasswordInput, PasswordStrength, PasswordVariants };
export default PasswordInput;
