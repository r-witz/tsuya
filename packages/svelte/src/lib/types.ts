/** What a Field gives its control to spread: the id its label points to and the ARIA of its hint or error. */
export interface FieldControlProps {
  id: string;
  'aria-describedby'?: string;
  'aria-invalid'?: true;
  'aria-errormessage'?: string;
  required?: true;
}
