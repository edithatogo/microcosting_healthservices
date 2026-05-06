const demoUrl = new URL("./demo/acute_2025.json", import.meta.url);

async function loadDemo() {
  const response = await fetch(demoUrl);
  if (!response.ok) {
    throw new Error(`Failed to load demo data: ${response.status}`);
  }
  return response.json();
}

function populateSelect(select, values, selectedValue) {
  select.replaceChildren();
  for (const value of values) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    option.selected = value === selectedValue;
    select.append(option);
  }
}

function renderRows(tbody, rows) {
  tbody.replaceChildren(
    ...rows.map((row) => {
      const tr = document.createElement("tr");
      tr.innerHTML = `<td>${row.DRG}</td><td>${row.LOS}</td><td>${row.NWAU}</td>`;
      return tr;
    }),
  );
}

const demo = await loadDemo();
const calculators = [demo.contract.calculator];
const years = [demo.contract.pricing_year];

const calculatorSelect = document.querySelector("#calculator");
const yearSelect = document.querySelector("#pricing-year");
const summary = document.querySelector("#summary");
const rows = document.querySelector("#rows");

populateSelect(calculatorSelect, calculators, demo.contract.calculator);
populateSelect(yearSelect, years, demo.contract.pricing_year);
summary.textContent = `Contract ${demo.contract.schema_version} · ${demo.contract.calculator} · ${demo.contract.pricing_year}`;
renderRows(rows, demo.rows);
