const http = require("http");
const sql = require("mssql");
const {
  DefaultAzureCredential,
  AzureCliCredential,
} = require("@azure/identity");

const PORT = 3000;
const SERVER = "ynov-sql-server-msimon.database.windows.net";
const DATABASE = "ynov-msimon-sql";

async function getProducts() {
  const credential = new AzureCliCredential(
    (options = { subscription: "2ce35cbb-52a5-4a7c-962a-570844f51275" }),
  );
  const tokenResponse = await credential.getToken(
    "https://database.windows.net/.default",
  );

  const config = {
    server: SERVER,
    database: DATABASE,
    authentication: {
      type: "azure-active-directory-access-token",
      options: { token: tokenResponse.token },
    },
    options: {
      encrypt: true,
      trustServerCertificate: false,
    },
  };

  const pool = await sql.connect(config);
  const result = await pool.request().query(`
    SELECT
      ProductID,
      Name,
      ProductNumber,
      Color,
      StandardCost,
      ListPrice,
      Size,
      Weight,
      ProductCategoryID,
      ProductModelID,
      SellStartDate,
      SellEndDate
    FROM SalesLT.Product
    ORDER BY Name
  `);
  await pool.close();
  return result.recordset;
}

function renderHTML(products) {
  const rows = products
    .map(
      (p) => `
      <tr>
        <td>${p.ProductID}</td>
        <td>${p.Name}</td>
        <td>${p.ProductNumber}</td>
        <td>${p.Color ?? "-"}</td>
        <td>${p.StandardCost.toFixed(2)}</td>
        <td>${p.ListPrice.toFixed(2)}</td>
        <td>${p.Size ?? "-"}</td>
        <td>${p.Weight != null ? p.Weight.toFixed(2) : "-"}</td>
      </tr>`,
    )
    .join("");

  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>SalesLT.Product - Azure SQL</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 2rem; background: #f5f5f5; }
    h1 { color: #0078d4; }
    table { border-collapse: collapse; width: 100%; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,.12); }
    th, td { padding: .6rem 1rem; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background: #0078d4; color: #fff; }
    tr:hover { background: #f0f6ff; }
    .meta { color: #666; margin-bottom: 1.5rem; }
  </style>
</head>
<body>
  <h1>SalesLT.Product</h1>
  <p class="meta">${products.length} produits &mdash; ${SERVER} / ${DATABASE}</p>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Nom</th>
        <th>N&deg; Produit</th>
        <th>Couleur</th>
        <th>Co&ucirc;t Standard</th>
        <th>Prix Liste</th>
        <th>Taille</th>
        <th>Poids</th>
      </tr>
    </thead>
    <tbody>${rows}</tbody>
  </table>
</body>
</html>`;
}

const server = http.createServer(async (req, res) => {
  if (req.url !== "/" && req.url !== "/favicon.ico") {
    res.writeHead(404);
    res.end("Not found");
    return;
  }
  if (req.url === "/favicon.ico") {
    res.writeHead(204);
    res.end();
    return;
  }

  try {
    const products = await getProducts();
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(renderHTML(products));
  } catch (err) {
    console.error(err);
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end("Erreur: " + err.message);
  }
});

server.listen(PORT, () => {
  console.log(`http://localhost:${PORT}`);
});
