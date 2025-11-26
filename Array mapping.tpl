___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Array mapping",
  "description": "",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "groupInput",
    "displayName": "Arrays to compare",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "arraySource1",
        "displayName": "Source 1",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "arraySource2",
        "displayName": "Source 2",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "groupMatchingKey",
    "displayName": "Matching key",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "keySource1",
        "displayName": "Source 1 (key)",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "keySource2",
        "displayName": "Source 2 (key)",
        "simpleValueType": true
      },
      {
        "type": "SELECT",
        "name": "matchingRule",
        "displayName": "Matching rule",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "s1EqualsS2",
            "displayValue": "S1 \u003d S2"
          },
          {
            "value": "s1ContainsS2",
            "displayValue": "S1 contains S2"
          },
          {
            "value": "s2ContainsS1",
            "displayValue": "S2 contains S1"
          }
        ],
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "groupOutput",
    "displayName": "Array output format",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "tableArrayOutput",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Your output key",
            "name": "outputCustomKey",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "From this source",
            "name": "fromSource",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "source1",
                "displayValue": "Source 1"
              },
              {
                "value": "source2",
                "displayValue": "Source 2"
              }
            ]
          },
          {
            "defaultValue": "",
            "displayName": "Get this key",
            "name": "getKeyValueFromSelectedSource",
            "type": "TEXT"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const log = require('logToConsole');
const getType = require('getType');
const makeString = require('makeString');

/**
 * Vérifie si un élément du tableau 1 correspond à un élément du tableau 2
 * selon la règle de correspondance spécifiée
 */

function isMatching(item1, item2, keySource1, keySource2, matchingRule) {
    const value1 = item1[keySource1];
    const value2 = item2[keySource2];

    if (value1 === undefined || value2 === undefined) {
        return false;
    }

    // Conversion en chaîne pour permettre les comparaisons
    const strValue1 = makeString(value1);
    const strValue2 = makeString(value2);

    let result = false;

    switch (matchingRule) {
        case 's1EqualsS2':
            result = (strValue1 === strValue2);
            return result;

        case 's1ContainsS2':
            result = (strValue1.indexOf(strValue2) !== -1);
            return result;

        case 's2ContainsS1':
            result = (strValue2.indexOf(strValue1) !== -1);
            return result;

        default:
            return false;
    }
}

/**
 * Fonction principale exécutée par le template
 */
function main() {
    // Récupérer les données d'entrée
    const arraySource1 = data.arraySource1;
    const arraySource2 = data.arraySource2;
    const keySource1 = data.keySource1;
    const keySource2 = data.keySource2;
    const matchingRule = data.matchingRule;
    const outputConfigTable = data.tableArrayOutput;

    // Vérification des types
    if (getType(arraySource1) !== 'array' || getType(arraySource2) !== 'array') {
        log('Erreur: arraySource1 et arraySource2 doivent être des tableaux');
        return [];
    }

    if (getType(keySource1) !== 'string' || getType(keySource2) !== 'string') {
        log('Erreur: keySource1 et keySource2 doivent être des chaînes de caractères');
        return [];
    }

    // Vérifier que matchingRule est une valeur valide
    const validRules = ['s1EqualsS2', 's1ContainsS2', 's2ContainsS1'];
    let isValidRule = false;
    for (let i = 0; i < validRules.length; i++) {
        if (matchingRule === validRules[i]) {
            isValidRule = true;
            break;
        }
    }

    if (!isValidRule) {
        log('Erreur: matchingRule doit être une des valeurs suivantes: s1EqualsS2, s1ContainsS2, s2ContainsS1');
        return [];
    }

    const resultArray = [];

    for (let i = 0; i < arraySource1.length; i++) {
        const item1 = arraySource1[i];

        for (let j = 0; j < arraySource2.length; j++) {
            const item2 = arraySource2[j];

            if (isMatching(item1, item2, keySource1, keySource2, matchingRule)) {

                const resultItem = {};

                for (let k = 0; k < outputConfigTable.length; k++) {
                    const config = outputConfigTable[k];
                    const outputKey = config.outputCustomKey;

                    let source;
                    if (config.fromSource === 'source1') {
                        source = item1;
                    } else if (config.fromSource === 'source2') {
                        source = item2;
                    } else {
                        continue;
                    }

                    const sourceKey = config.getKeyValueFromSelectedSource;
                    resultItem[outputKey] = (source && source.hasOwnProperty(sourceKey)) ? source[sourceKey] : undefined;
                }

                resultArray.push(resultItem);
            }
        }
    }
    return resultArray;
}

// Point d'entrée du template
return main();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Match entre item_id e-commerce et Firestore avec s1ContainsS2
  code: |2-
      const mockData = {
        arraySource1: [
          {
            price: 89.9,
            discount: 0,
            index: 0,
            item_id: "04700-0557_03J_00A",
            item_name: "Jean regular homme coton biologique",
            item_category: "Channable-FR",
            item_variant: "38 / DENIM BRUT",
            item_list_name: "nosto",
            item_list_id: "nosto|derniers-produits-vus",
            item_gtin: 3608523969506,
            item_shopify_id: 7934844567809,
            item_instock: "true",
            item_image_url: "https://cdn.shopify.com/s/files/1/0639/8266/5985/files/04700_0557_03511_PO_FA_F1XX.jpg",
            item_color: "DENIM BRUT"
          }
        ],
        arraySource2: [
          {
            genre: "MASCULIN",
            item_category_2: "PANTALON",
            brand: "CYRILLUS",
            made_in: "Maroc",
            secteur: "HOMME",
            item_id: "04700-0557"
          }
        ],
        keySource1: "item_id",
        keySource2: "item_id",
        matchingRule: "s1ContainsS2",
        tableArrayOutput: [
          { outputCustomKey: "item_id", fromSource: "source1", getKeyValueFromSelectedSource: "item_id" },
          { outputCustomKey: "item_category", fromSource: "source2", getKeyValueFromSelectedSource: "secteur" },
          { outputCustomKey: "item_category2", fromSource: "source2", getKeyValueFromSelectedSource: "item_category_2" },
          { outputCustomKey: "item_made_in", fromSource: "source2", getKeyValueFromSelectedSource: "made_in" },
          { outputCustomKey: "item_genre", fromSource: "source2", getKeyValueFromSelectedSource: "genre" },
          { outputCustomKey: "item_brand", fromSource: "source2", getKeyValueFromSelectedSource: "brand" },
          { outputCustomKey: "price", fromSource: "source1", getKeyValueFromSelectedSource: "price" },
          { outputCustomKey: "item_name", fromSource: "source1", getKeyValueFromSelectedSource: "item_name" },
          { outputCustomKey: "item_color", fromSource: "source1", getKeyValueFromSelectedSource: "item_color" }
        ]
      };

      // Run test
      let result = runCode(mockData);

      // Assert
      assertThat(result).isArray();
      assertThat(result.length).isEqualTo(1);
      assertThat(result[0].item_id).isEqualTo("04700-0557_03J_00A");
      assertThat(result[0].item_category).isEqualTo("HOMME");
      assertThat(result[0].item_category2).isEqualTo("PANTALON");
      assertThat(result[0].item_made_in).isEqualTo("Maroc");
      assertThat(result[0].item_genre).isEqualTo("MASCULIN");
      assertThat(result[0].item_brand).isEqualTo("CYRILLUS");
      assertThat(result[0].price).isEqualTo(89.9);
      assertThat(result[0].item_name).isEqualTo("Jean regular homme coton biologique");
      assertThat(result[0].item_color).isEqualTo("DENIM BRUT");
- name: Match entre item_id e-commerce et Firestore pour un produit féminin
  code: |2-
      const mockData = {
        arraySource1: [
          {
            price: 44.9,
            discount: 10,
            index: 1,
            item_id: "72029-0739_00H_003",
            item_name: "Blouse Fille broderie anglaise",
            item_category: "Blouses pour fille",
            item_variant: "4A / ECRU",
            item_list_name: "nosto",
            item_list_id: "nosto|derniers-produits-vus",
            item_gtin: 3608524513104,
            item_instock: "true",
            item_color: "ECRU",
            item_stickers_value: "-10€"
          }
        ],
        arraySource2: [
          {
            genre: "FEMININ",
            item_category_2: "VESTE",
            brand: "CYRILLUS",
            made_in: "Bulgarie",
            secteur: "FEMME",
            item_id: "00100-0540"
          }
        ],
        keySource1: "item_id",
        keySource2: "item_id",
        matchingRule: "s1ContainsS2",
        tableArrayOutput: [
          { outputCustomKey: "item_id", fromSource: "Source 1", getKeyValueFromSelectedSource: "item_id" },
          { outputCustomKey: "item_category", fromSource: "Source 2", getKeyValueFromSelectedSource: "secteur" },
          { outputCustomKey: "item_category2", fromSource: "Source 2", getKeyValueFromSelectedSource: "item_category_2" },
          { outputCustomKey: "item_made_in", fromSource: "Source 2", getKeyValueFromSelectedSource: "made_in" },
          { outputCustomKey: "item_genre", fromSource: "Source 2", getKeyValueFromSelectedSource: "genre" },
          { outputCustomKey: "item_brand", fromSource: "Source 2", getKeyValueFromSelectedSource: "brand" },
          { outputCustomKey: "price", fromSource: "Source 1", getKeyValueFromSelectedSource: "price" },
          { outputCustomKey: "discount", fromSource: "Source 1", getKeyValueFromSelectedSource: "discount" },
          { outputCustomKey: "item_name", fromSource: "Source 1", getKeyValueFromSelectedSource: "item_name" },
          { outputCustomKey: "item_color", fromSource: "Source 1", getKeyValueFromSelectedSource: "item_color" },
          { outputCustomKey: "item_stickers", fromSource: "Source 1", getKeyValueFromSelectedSource: "item_stickers_value" }
        ]
      };

      // Run test
      let result = runCode(mockData);

      // Assert
      assertThat(result).isArray();
      // Aucune correspondance attendue car les IDs ne correspondent pas
      assertThat(result.length).isEqualTo(0);
- name: Multiple correspondances pour plusieurs produits (scénario réel)
  code: "  const mockData = {\n    arraySource1: [\n      {\n        price: 89.9,\n\
    \        item_id: \"04700-0557_03J_00A\",\n        item_name: \"Jean regular homme\
    \ coton biologique\",\n        item_color: \"DENIM BRUT\"\n      },\n      {\n\
    \        price: 44.9,\n        item_id: \"00100-0540_00H_003\",\n        item_name:\
    \ \"Veste femme en lin\",\n        item_color: \"ECRU\"\n      }\n    ],\n   \
    \ arraySource2: [\n      {\n        genre: \"MASCULIN\",\n        item_category_2:\
    \ \"PANTALON\",\n        brand: \"CYRILLUS\",\n        made_in: \"Maroc\",\n \
    \       secteur: \"HOMME\",\n        item_id: \"04700-0557\"\n      },\n     \
    \ {\n        genre: \"FEMININ\",\n        item_category_2: \"VESTE\",\n      \
    \  brand: \"CYRILLUS\",\n        made_in: \"Bulgarie\",\n        secteur: \"FEMME\"\
    ,\n        item_id: \"00100-0540\"\n      }\n    ],\n    keySource1: \"item_id\"\
    ,\n    keySource2: \"item_id\",\n    matchingRule: \"s1ContainsS2\",\n    tableArrayOutput:\
    \ [\n      { outputCustomKey: \"item_id\", fromSource: \"source1\", getKeyValueFromSelectedSource:\
    \ \"item_id\" },\n      { outputCustomKey: \"item_name\", fromSource: \"source1\"\
    , getKeyValueFromSelectedSource: \"item_name\" },\n      { outputCustomKey: \"\
    price\", fromSource: \"source1\", getKeyValueFromSelectedSource: \"price\" },\n\
    \      { outputCustomKey: \"item_color\", fromSource: \"source1\", getKeyValueFromSelectedSource:\
    \ \"item_color\" },\n      { outputCustomKey: \"item_category\", fromSource: \"\
    source2\", getKeyValueFromSelectedSource: \"secteur\" },\n      { outputCustomKey:\
    \ \"item_category2\", fromSource: \"source2\", getKeyValueFromSelectedSource:\
    \ \"item_category_2\" },\n      { outputCustomKey: \"item_made_in\", fromSource:\
    \ \"source2\", getKeyValueFromSelectedSource: \"made_in\" },\n      { outputCustomKey:\
    \ \"item_genre\", fromSource: \"source2\", getKeyValueFromSelectedSource: \"genre\"\
    \ },\n      { outputCustomKey: \"item_brand\", fromSource: \"source2\", getKeyValueFromSelectedSource:\
    \ \"brand\" }\n    ]\n  };\n\n  // Run test\n  let result = runCode(mockData);\n\
    \n  // Assert\n  assertThat(result).isArray();\n  assertThat(result.length).isEqualTo(2);\n\
    \  \n  // Vérifier le premier résultat (homme)\n  assertThat(result[0].item_id).isEqualTo(\"\
    04700-0557_03J_00A\");\n  assertThat(result[0].item_name).isEqualTo(\"Jean regular\
    \ homme coton biologique\");\n  assertThat(result[0].item_category).isEqualTo(\"\
    HOMME\");\n  assertThat(result[0].item_genre).isEqualTo(\"MASCULIN\");\n  assertThat(result[0].item_category2).isEqualTo(\"\
    PANTALON\");\n  \n  // Vérifier le deuxième résultat (femme)\n  assertThat(result[1].item_id).isEqualTo(\"\
    00100-0540_00H_003\");\n  assertThat(result[1].item_name).isEqualTo(\"Veste femme\
    \ en lin\");\n  assertThat(result[1].item_category).isEqualTo(\"FEMME\");\n  assertThat(result[1].item_genre).isEqualTo(\"\
    FEMININ\");\n  assertThat(result[1].item_category2).isEqualTo(\"VESTE\");"
- name: Entrées non valides
  code: "  const mockData1 = {\n    arraySource1: \"not an array\",\n    arraySource2:\
    \ [],\n    keySource1: \"id\",\n    keySource2: \"code\",\n    matchingRule: \"\
    s1EqualsS2\",\n    tableArrayOutput: []\n  };\n\n  // Setup - matchingRule invalide\n\
    \  const mockData2 = {\n    arraySource1: [],\n    arraySource2: [],\n    keySource1:\
    \ \"id\",\n    keySource2: \"code\",\n    matchingRule: \"invalid_rule\",\n  \
    \  tableArrayOutput: []\n  };\n\n  // Run tests\n  let result1 = runCode(mockData1);\n\
    \  let result2 = runCode(mockData2);\n\n  // Assert\n  assertThat(result1).isArray();\n\
    \  assertThat(result1.length).isEqualTo(0);\n  \n  assertThat(result2).isArray();\n\
    \  assertThat(result2.length).isEqualTo(0);"
setup: ''


___NOTES___

Created on 26/11/2025 13:55:50


