import { BlobServiceClient, ContainerClient } from "@azure/storage-blob";
import { DefaultAzureCredential } from "@azure/identity";
import { v4 as uuidv4 } from "uuid";

const ACCOUNT_NAME = process.env.AZURE_STORAGE_ACCOUNT_NAME || "msimonblob";
const CONTAINER_NAME = process.env.AZURE_STORAGE_CONTAINER_NAME || "files";
const ACCOUNT_URL = `https://${ACCOUNT_NAME}.blob.core.windows.net`;

let containerClient: ContainerClient | null = null;

async function getContainerClient(): Promise<ContainerClient> {
  if (containerClient) {
    return containerClient;
  }

  const credential = new DefaultAzureCredential();
  const blobServiceClient = new BlobServiceClient(ACCOUNT_URL, credential);
  containerClient = blobServiceClient.getContainerClient(CONTAINER_NAME);
  // Don't create container - assume it exists

  return containerClient;
}

export async function uploadImage(
  buffer: Buffer,
  originalName: string,
  mimeType: string,
): Promise<string> {
  const container = await getContainerClient();

  // Generate unique filename
  const extension = originalName.split(".").pop() || "jpg";
  const blobName = `expenses/${uuidv4()}.${extension}`;

  const blockBlobClient = container.getBlockBlobClient(blobName);

  await blockBlobClient.upload(buffer, buffer.length, {
    blobHTTPHeaders: {
      blobContentType: mimeType,
    },
  });

  // Return the blob name (not the URL) - we'll serve via proxy
  return blobName;
}

export async function getImageBuffer(
  blobName: string,
): Promise<{ buffer: Buffer; contentType: string }> {
  const container = await getContainerClient();
  const blockBlobClient = container.getBlockBlobClient(blobName);

  const downloadResponse = await blockBlobClient.download(0);
  const chunks: Buffer[] = [];

  for await (const chunk of downloadResponse.readableStreamBody as NodeJS.ReadableStream) {
    chunks.push(Buffer.from(chunk));
  }

  return {
    buffer: Buffer.concat(chunks),
    contentType: downloadResponse.contentType || "application/octet-stream",
  };
}

export async function deleteImage(blobName: string): Promise<void> {
  const container = await getContainerClient();

  // Handle both old URLs and new blob names
  let actualBlobName = blobName;
  if (blobName.startsWith("http")) {
    const url = new URL(blobName);
    actualBlobName = url.pathname.split("/").slice(2).join("/");
  }

  const blockBlobClient = container.getBlockBlobClient(actualBlobName);
  await blockBlobClient.deleteIfExists();
}
