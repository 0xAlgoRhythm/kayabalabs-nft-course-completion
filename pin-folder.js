import fs from "fs";
import path from "path";
import FormData from "form-data";
import axios from "axios";

const JWT = process.env.PINATA_JWT;
if (!JWT) throw new Error("Missing PINATA_JWT env var");

const folder = process.argv[2] || "course-metadata";
const limit = Number(process.argv[3] || 10); // default 10

const url = "https://api.pinata.cloud/pinning/pinFileToIPFS";

function isJsonName0toN(name, n) {
  // matches "0.json"..."(n-1).json"
  const m = name.match(/^(\d+)\.json$/);
  if (!m) return false;
  const id = Number(m[1]);
  return Number.isInteger(id) && id >= 0 && id < n;
}

async function pinFirstN() {
  const data = new FormData({ maxDataSize: Infinity });

  for (let i = 0; i < limit; i++) {
    const filePath = path.join(folder, `${i}.json`);
    if (!fs.existsSync(filePath)) {
      throw new Error(`Missing file: ${filePath}`);
    }
    data.append("file", fs.createReadStream(filePath), {
      filepath: `${path.basename(folder)}/${i}.json`, // keeps folder structure
    });
  }

  data.append(
    "pinataMetadata",
    JSON.stringify({ name: `kayabalabs-metadata-first-${limit}` })
  );

  try {
    const res = await axios.post(url, data, {
      headers: {
        ...data.getHeaders(),
        Authorization: `Bearer ${JWT}`,
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
      timeout: 0,
    });

    console.log("Pinned folder CID:", res.data.IpfsHash);
    console.log("Example tokenURI:", `ipfs://${res.data.IpfsHash}/0.json`);
  } catch (err) {
    console.error(
      "Upload failed:",
      err?.response?.status,
      err?.response?.data || err.message
    );
    process.exit(1);
  }
}

pinFirstN();
