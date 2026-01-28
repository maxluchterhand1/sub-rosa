# Sub Rosa
##  "If you can't read it, you can't leak it."

Sub Rosa is a secure, serverless secret-sharing application built on Google Cloud Platform (GCP). It generates one-time-use links for sensitive information. The unique architecture ensures that the encryption key never touches the database, guaranteeing that even the server administrators cannot read the stored secrets.

### 🏗 Repository Structure

This is a monorepo containing the frontend, backend, and infrastructure code.

```

sub-rosa/
├── backend/          # Node.js (Express) application running on Cloud Run
├── frontend/         # Vanilla HTML/JS implementation (Client-Side Crypto)
└── infrastructure/   # Terraform modules for full GCP provisioning
```

### 🔐 Security Architecture

The "Stateless Key" Pattern

Unlike traditional secret managers, Sub Rosa separates the Storage ID from the Encryption Key.

1. Client-Side Creation: The browser generates a random AES-256 key and IV.

2. Encryption: The message is encrypted locally.

3. Storage: The encrypted ciphertext and the IV are sent to the backend and stored in Firestore. The key is never sent to the server.

4. Link Generation: The link provided to the user contains the Firestore ID and the Key (in the URL fragment).
   - Example: https://sub-rosa.dev/#id=...&key=...
   - Because the key is in the hash fragment (#), it is never sent to the server during the request.

5. Burn on Read: When the recipient opens the link, the backend retrieves and immediately deletes the encrypted blob. The browser then decrypts it locally using the key from the URL.
