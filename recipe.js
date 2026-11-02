// JavaScript recipe DSL — builder + tagged-template style approximating macros

function g(n) { return ['g', n]; }
function ml(n) { return ['ml', n]; }
const pinch = 'pinch';
const toTaste = 'to-taste';

function ing(strings, ...values) {
  const name = strings[0];
  return (qty) => [name, qty];
}

class RecipeBuilder {
  constructor(name) {
    this._name = name;
    this._servings = 1;
    this._ingredients = [];
    this._steps = [];
  }
  servings(n) { this._servings = n; return this; }
  ingredients(...ings) { this._ingredients = ings; return this; }
  steps(...steps) { this._steps = steps; return this; }
  build() {
    return {
      name: this._name,
      servings: this._servings,
      ingredients: this._ingredients,
      steps: this._steps
    };
  }
}

export function recipe(strings, ...values) {
  const name = strings[0];
  return new RecipeBuilder(name);
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

export { g, ml, pinch, toTaste, ing };
