# Update Wanderlog — Reference

配套 [SKILL.md](SKILL.md)。執行 API 同步或除錯時讀本檔。

## 依賴

```bash
npm init -y && npm install wanderlog-mcp
```

```javascript
import { RestClient } from 'wanderlog-mcp/dist/transport/rest.js';
import { ShareDBClient } from 'wanderlog-mcp/dist/transport/sharedb.js';
import { loadConfig } from 'wanderlog-mcp/dist/config.js';
import { buildPlaceBlock } from 'wanderlog-mcp/dist/tools/shared.js';
```

環境變數：`WANDERLOG_COOKIE` = 使用者提供的 `connect.sid` value。

---

## Note 格式：`defaultNoteOps`

```javascript
function defaultNoteOps(zh, transport, highlights = []) {
  const ops = [
    { insert: zh, attributes: { bold: true } },
    { insert: '\n' },
  ];
  if (transport) ops.push({ insert: `交通：${transport}\n` });
  for (const point of highlights) {
    ops.push({ insert: `• ${point}\n` });
  }
  return ops;
}

// 範例
defaultNoteOps('河口湖遊覽船', '搭紅線至遊覽船・纜車入口', [
  '湖上遠眺富士山',
  '約 20 分環湖',
  '可配纜車同遊',
]);
```

---

## 可複製腳本模板

```javascript
import { RestClient } from 'wanderlog-mcp/dist/transport/rest.js';
import { ShareDBClient } from 'wanderlog-mcp/dist/transport/sharedb.js';
import { loadConfig } from 'wanderlog-mcp/dist/config.js';
import { buildPlaceBlock } from 'wanderlog-mcp/dist/tools/shared.js';

const TRIP_KEY = 'YOUR_TRIP_KEY';
const SECTION_HEADING = '富士山河口湖景點';
const SEARCH_CENTER = { latitude: 35.498, longitude: 138.768 };
const SEARCH_RADIUS = 50000;

const PLACES = [
  {
    search: 'Kawaguchiko Pleasure Boat',
    placeId: 'ChIJ4--VEiZeGWARcfjS0dFw7B0',
    zh: '河口湖遊覽船',
    transport: '搭紅線至遊覽船・纜車入口',
    highlights: ['湖上遠眺富士山', '約 20 分環湖', '可配纜車同遊'],
  },
  // ...
];

function defaultNoteOps(zh, transport, highlights = []) {
  const ops = [
    { insert: zh, attributes: { bold: true } },
    { insert: '\n' },
  ];
  if (transport) ops.push({ insert: `交通：${transport}\n` });
  for (const point of highlights) {
    ops.push({ insert: `• ${point}\n` });
  }
  return ops;
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function noteContainsZh(block, zh) {
  return (block.text?.ops ?? []).some(
    (o) => typeof o.insert === 'string' && o.insert.includes(zh),
  );
}

async function resolvePlace(rest, item, center, radius) {
  if (item.placeId) {
    try {
      return await rest.getPlaceDetails(item.placeId);
    } catch {
      /* fall through */
    }
  }
  const predictions = await rest.searchPlacesAutocomplete({
    input: item.search,
    sessionToken: crypto.randomUUID(),
    location: center,
    radius,
  });
  const valid = predictions.filter((p) => p.place_id);
  if (valid.length === 0) throw new Error(`No autocomplete: ${item.search}`);
  for (const pred of valid.slice(0, 5)) {
    try {
      return await rest.getPlaceDetails(pred.place_id);
    } catch {
      continue;
    }
  }
  throw new Error(`Place details failed: ${item.search}`);
}

async function addPlace(config, rest, userId, tripKey, sectionIndex, place, noteOps) {
  const client = new ShareDBClient(config, tripKey);
  await client.connect();
  await client.subscribe();

  const { tripPlan: trip } = await rest.getTripWithResources(tripKey);
  const section = trip.itinerary.sections[sectionIndex];
  const insertIndex = section.blocks.length;
  const blockPath = ['itinerary', 'sections', sectionIndex, 'blocks', insertIndex];

  await client.submit([
    { p: blockPath, li: buildPlaceBlock(place, userId) },
    { p: [...blockPath, 'text'], t: 'rich-text', o: noteOps },
  ]);
  return place.name;
}

async function updateNote(config, tripKey, blockPath, noteOps) {
  const client = new ShareDBClient(config, tripKey);
  await client.connect();
  await client.subscribe();
  await client.submit([{ p: [...blockPath, 'text'], t: 'rich-text', o: noteOps }]);
}

async function findTripKey(rest, nameHint) {
  const user = await rest.getUser();
  const trips = await rest.listTrips(user.id);
  const trip = trips.find(
    (t) => t.name.includes(nameHint) || t.title?.includes(nameHint),
  );
  if (!trip) throw new Error(`Trip not found: ${nameHint}`);
  return trip.key;
}

async function main() {
  const config = loadConfig();
  const rest = new RestClient(config);
  const user = await rest.getUser();

  const tripKey = TRIP_KEY || (await findTripKey(rest, 'Tokyo'));
  let { tripPlan: trip } = await rest.getTripWithResources(tripKey);
  const sectionIndex = trip.itinerary.sections.findIndex(
    (s) => s.heading === SECTION_HEADING,
  );
  if (sectionIndex < 0) {
    const headings = trip.itinerary.sections.map((s) => s.heading).filter(Boolean);
    throw new Error(`Section "${SECTION_HEADING}" not found. Available: ${headings.join(', ')}`);
  }

  for (const item of PLACES) {
    ({ tripPlan: trip } = await rest.getTripWithResources(tripKey));
    const section = trip.itinerary.sections[sectionIndex];

    if (section.blocks.some((b) => noteContainsZh(b, item.zh))) {
      console.log(`Skip: ${item.zh}`);
      continue;
    }

    const place = await resolvePlace(rest, item, SEARCH_CENTER, SEARCH_RADIUS);
    const name = await addPlace(
      config,
      rest,
      user.id,
      tripKey,
      sectionIndex,
      place,
      defaultNoteOps(item.zh, item.transport, item.highlights ?? []),
    );
    console.log(`Added: ${name}`);
    await sleep(1500);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
```

執行：

```bash
WANDERLOG_COOKIE='s%3A...' node wanderlog-sync.mjs
```

---

## Melessa 常用行程（參考，以 API 即時為準）

| 行程 | trip key | 常用 section |
| --- | --- | --- |
| 前往Tokyo的旅行 | `afnmohflkhpeqqpp` | `東京景点`、`富士山河口湖景點` |

---

## 河口湖／富士山：搜尋對照（實測）

| 目標中文名 | 建議 search | 可用 place_id |
| --- | --- | --- |
| 河口湖遊覽船 | `Kawaguchiko Pleasure Boat` 或 `河口湖遊覽船` | `ChIJ4--VEiZeGWARcfjS0dFw7B0` |
| 湖山亭產屋前 | `Ubuya` | `ChIJK4evUjdeGWARU3gkvo_nU_4` |
| 大石公園 | `Oishi Park Kawaguchiko` | `ChIJlSsLjKZfGWARBCllOgtTLqI` |
| 新倉山淺間公園（忠靈塔） | `Chureito Pagoda` | `ChIJc6BS_UxnGWARmeeuIEnjV9o` |

搜尋中心：`{ latitude: 35.498, longitude: 138.768 }`，`radius: 50000`。

---

## ShareDB rich-text 範例

```javascript
{
  p: ['itinerary', 'sections', sectionIndex, 'blocks', insertIndex, 'text'],
  t: 'rich-text',
  o: [
    { insert: '河口湖遊覽船', attributes: { bold: true } },
    { insert: '\n' },
    { insert: '交通：搭紅線至遊覽船・纜車入口\n' },
    { insert: '• 湖上遠眺富士山\n' },
    { insert: '• 約 20 分環湖\n' },
    { insert: '• 可配纜車同遊\n' },
  ],
}
```

---

## wanderlog-mcp MCP（可選）

MCP 工具 `wanderlog_add_place` 的 `note` 參數為**純文字**（不支援 bold／bullet 結構）。要預設 note 格式時仍用本 reference 的 ShareDB rich-text 腳本。
