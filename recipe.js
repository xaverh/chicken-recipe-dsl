// JavaScript recipe DSL skeleton

export function makeRecipe(name, servings, ingredients, steps) {
  return { name, servings, ingredients, steps };
}

function isNumericQuantity(q) {
  return Array.isArray(q) && typeof q[1] === 'number';
}

export function scaleQuantity(q, factor) {
  if (isNumericQuantity(q)) return [q[0], q[1] * factor];
  return q;
}

export function scaleRecipe(r, factor) {
  return {
    ...r,
    servings: r.servings * factor,
    ingredients: r.ingredients.map(([name, q]) => [name, scaleQuantity(q, factor)])
  };
}

function quantityToString(q) {
  if (isNumericQuantity(q)) return `${q[1]} ${q[0]}`;
  return String(q);
}

export function recipeToHtml(r) {
  const ings = r.ingredients.map(([n, q]) => `<li>${n}: ${quantityToString(q)}</li>`).join('');
  const stps = r.steps.map(s => `<li>${s}</li>`).join('');
  return `<article><h1>${r.name}</h1><p>Servings: ${r.servings}</p><h2>Ingredients</h2><ul>${ings}</ul><h2>Steps</h2><ol>${stps}</ol></article>`;
}
