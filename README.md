# sGTM Variable Template: Array Mapping

This Server-Side Google Tag Manager (sGTM) variable template allows you to **merge two arrays of objects** into a single, custom-formatted array. It provides flexible matching rules (equals, contains) to join data from different sources, such as incoming event data and external API/Firestore responses.

<img width="1385" height="969" alt="image" src="https://github.com/user-attachments/assets/1e0d0868-e4ac-481d-952f-7d9de4a05266" />

## 🚀 Why use this?

In server-side tagging, you often fetch enrichment data (like product margins or categories) from an external source (Firestore, Google Sheets, API). You end up with two arrays:
1.  **Event Items :** The products in your GA4 `view_item_list` event.
2.  **Enrichment Data :** A list of product details fetched from your database.

Standard GTM features don't offer a way to "SQL Join" these arrays. This template solves that problem by letting you map, merge, and format them into a clean new array ready for your tags.

## ✨ Key features

* **Flexible matching :** Join arrays not just by exact match, but also using "contains" logic (useful when one ID has a variant suffix like `SKU_123_XL` and the other is just `SKU_123`).
* **Custom output :** You define exactly what the resulting array looks like. You can mix and match fields from both Source 1 and Source 2.
* **Type safety :** Automatically handles type conversions to ensure comparisons work smoothly.

## ⚙️ Configuration

### 1. Arrays to compare
* **Source 1 :** The first array (usually your Event Data items, e.g., `{{Event Data - items}}`).
* **Source 2 :** The second array (e.g., the output from a Firestore Lookup variable).

### 2. Matching key
Define how the two arrays should be joined.
* **Source 1 (key) :** The property name in Source 1 to match against (e.g., `item_id`).
* **Source 2 (key) :** The property name in Source 2 to match against (e.g., `id`).
* **Matching rule :**
    * `S1 = S2` (Exact match)
    * `S1 contains S2` (Useful if Source 1 is `PRODUCT_123_VAR` and Source 2 is `PRODUCT_123`)
    * `S2 contains S1`

### 3. Array output format
Build your new object structure using a simple table. For each field you want in the result:
* **Your output key :** The name of the key in the final object (e.g., `margin`).
* **From this source :** Choose whether to grab the value from **Source 1** or **Source 2**.
* **Get this key :** The property name to extract from that source (e.g., `profit_margin`).

## 📦 Output

Returns an **Array of Objects**. Each object contains only the fields you defined in the "Array output format" section.

## 📝 Example Use Case

**Goal :** Enrich GA4 items with "Brand" and "Margin" from a database.

1.  **Source 1 (GA4) :** `[{ "item_id": "A_123", "price": 10 }]`
2.  **Source 2 (DB) :** `[{ "id": "A", "brand": "Nike", "margin": 5 }]`
3.  **Config :**
    * Match Key : `item_id` vs `id`
    * Rule : `S1 contains S2`
    * Output Table :
        * `final_id` -> Source 1 -> `item_id`
        * `final_brand` -> Source 2 -> `brand`
        * `final_margin` -> Source 2 -> `margin`
4.  **Result :** `[{ "final_id": "A_123", "final_brand": "Nike", "final_margin": 5 }]`

## 🛠️ Installation

1.  Download the `Array mapping.tpl` file.
2.  In sGTM, go to **Templates** > **New** > **Import**.
3.  Select the file, save, and publish.

