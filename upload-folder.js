import fs from "fs";
import FormData from "form-data";
import rfs from "recursive-fs";
import basePathConverter from "base-path-converter";
import axios from "axios";
import path from "path";

const apiKey = process.env.LIGHTHOUSE_API_KEY;
if (!apiKey) throw new Error("Missing LIGHTHOUSE_API_KEY env var");

const folder = process.argv[2] || "course-metadata";
const folderPath = path.resolve(folder);

// Lighthouse upload endpoint
const url = "https://node.lighthouse.storage/api/v0/add";

async function uploadFolder() {
  const { files } = await rfs.read(folderPath);

  const data = new FormData({ maxDataSize: Infinity });

  for (const file of files) {
    data.append("file", fs.createReadStream(file), {
      filepath: basePathConverter(folderPath, file), // keeps folder structure
    });
  }

  try {
    const res = await axios.post(url, data, {
      headers: {
        ...data.getHeaders(),
        Authorization: `Bearer ${apiKey}`,
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
      timeout: 0,
    });

    // Lighthouse returns an array sometimes; handle both shapes safely
    const out = res.data;
    console.log("Raw response:", out);

    // Try to find the "root" CID (often last item if array)
    const root = Array.isArray(out) ? out[out.length - 1] : out;
    const cid = root?.Hash || root?.data?.Hash;

    if (!cid) {
      console.log("Could not auto-detect CID. Check Raw response above.");
      return;
    }

    console.log("Root CID:", cid);
    console.log("Base URI:", `ipfs://${cid}/`);
    console.log("Example tokenURI:", `ipfs://${cid}/0.json`);
  } catch (e) {
    console.error("Upload failed:");
    console.error("Status:", e?.response?.status);
    console.error("Data:", e?.response?.data || e.message);
    process.exit(1);
  }
}

uploadFolder();
// Metadata generation script for Kayaba Labs Soulbound NFT Course Completion certificates