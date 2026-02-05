import { BlobServiceClient, ContainerClient } from '@azure/storage-blob';
import { DefaultAzureCredential } from '@azure/identity';
import { v4 as uuidv4 } from 'uuid';

const ACCOUNT_NAME = process.env.AZURE_STORAGE_ACCOUNT_NAME || 'msimonblob';
const CONTAINER_NAME = process.env.AZURE_STORAGE_CONTAINER_NAME || 'files';
const ACCOUNT_URL = `https://${ACCOUNT_NAME}.blob.core.windows.net`;

let containerClient: ContainerClient | null = null;

async function getContainerClient(): Promise<ContainerClient> {
  if (containerClient) {
    return containerClient;
  }

  const credential = new DefaultAzureCredential();
  const blobServiceClient = new BlobServiceClient(ACCOUNT_URL, credential);
  containerClient = blobServiceClient.getContainerClient(CONTAINER_NAME);
  await containerClient.createIfNotExists({ access: 'blob' });
  
  return containerClient;
}

export async function uploadImage(
  buffer: Buffer, 
  originalName: string,
  mimeType: string
): Promise<string> {
  const container = await getContainerClient();
  
  // Generate unique filename
  const extension = originalName.split('.').pop() || 'jpg';
  const blobName = `expenses/${uuidv4()}.${extension}`;
  
  const blockBlobClient = container.getBlockBlobClient(blobName);
  
  await blockBlobClient.upload(buffer, buffer.length, {
    blobHTTPHeaders: {
      blobContentType: mimeType,
    },
  });
  
  return blockBlobClient.url;
}

export async function deleteImage(imageUrl: string): Promise<void> {
  const container = await getContainerClient();
  
  // Extract blob name from URL
  const url = new URL(imageUrl);
  const blobName = url.pathname.split('/').slice(2).join('/');
  
  const blockBlobClient = container.getBlockBlobClient(blobName);
  await blockBlobClient.deleteIfExists();
}

export async function listImages(): Promise<string[]> {
  const container = await getContainerClient();
  const urls: string[] = [];
  
  for await (const blob of container.listBlobsFlat({ prefix: 'expenses/' })) {
    const blockBlobClient = container.getBlockBlobClient(blob.name);
    urls.push(blockBlobClient.url);
  }
  
  return urls;
}
