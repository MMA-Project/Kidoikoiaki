const { BlobServiceClient } = require("@azure/storage-blob");
const { DefaultAzureCredential } = require("@azure/identity");
const path = require("path");
const fs = require("fs");

const ACCOUNT_NAME = "msimonblob";
const CONTAINER_NAME = "files";
const ACCOUNT_URL = `https://${ACCOUNT_NAME}.blob.core.windows.net`;

async function getContainerClient() {
  const credential = new DefaultAzureCredential();
  const blobServiceClient = new BlobServiceClient(ACCOUNT_URL, credential);
  const containerClient = blobServiceClient.getContainerClient(CONTAINER_NAME);
  await containerClient.createIfNotExists();
  return containerClient;
}

async function list() {
  const containerClient = await getContainerClient();
  let count = 0;
  for await (const blob of containerClient.listBlobsFlat()) {
    const size = blob.properties.contentLength;
    const date = blob.properties.lastModified.toISOString();
    console.log(`  ${blob.name}  (${size} bytes, ${date})`);
    count++;
  }
  if (count === 0) {
    console.log("Aucun fichier dans le container.");
  } else {
    console.log(`\n${count} fichier(s) au total.`);
  }
}

async function upload(filePath) {
  if (!filePath) {
    console.error("Usage: node index.js upload <chemin-du-fichier>");
    process.exit(1);
  }
  if (!fs.existsSync(filePath)) {
    console.error(`Fichier introuvable: ${filePath}`);
    process.exit(1);
  }
  const blobName = path.basename(filePath);
  const containerClient = await getContainerClient();
  const blockBlobClient = containerClient.getBlockBlobClient(blobName);
  const data = fs.readFileSync(filePath);
  await blockBlobClient.upload(data, data.length);
  console.log(`"${blobName}" uploaded.`);
}

async function remove(blobName) {
  if (!blobName) {
    console.error("Usage: node index.js delete <nom-du-fichier>");
    process.exit(1);
  }
  const containerClient = await getContainerClient();
  const blockBlobClient = containerClient.getBlockBlobClient(blobName);
  await blockBlobClient.delete();
  console.log(`"${blobName}" deleted.`);
}

async function download(blobName) {
  if (!blobName) {
    console.error("Usage: node index.js download <nom-du-fichier>");
    process.exit(1);
  }
  const containerClient = await getContainerClient();
  const blockBlobClient = containerClient.getBlockBlobClient(blobName);
  const response = await blockBlobClient.download(0);
  const chunks = [];
  for await (const chunk of response.readableStreamBody) {
    chunks.push(chunk);
  }
  fs.writeFileSync(blobName, Buffer.concat(chunks));
  console.log(`"${blobName}" downloaded.`);
}

async function main() {
  const [command, arg] = process.argv.slice(2);

  switch (command) {
    case "list":
      return list();
    case "upload":
      return upload(arg);
    case "download":
      return download(arg);
    case "delete":
      return remove(arg);
    default:
      console.log("Usage:");
      console.log("  node index.js list                 Lister les fichiers");
      console.log("  node index.js upload <fichier>      Uploader un fichier");
      console.log(
        "  node index.js download <nom>        Telecharger un fichier",
      );
      console.log("  node index.js delete <nom>          Supprimer un fichier");
  }
}

main().catch((err) => {
  console.error("Erreur:", err.message);
  process.exit(1);
});
