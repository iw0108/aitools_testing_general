/**
 * TEMP: CodeRabbit rule probe — delete after verifying .coderabbit.yaml.
 * Expect flags: console.*, unused vars, missing list keys, inline styles,
 * unhandled fetch/async, hardcoded secret, duplicate logic.
 */
const PROBE_API_SECRET = "sk_live_fake_coderabbit_probe_not_real";

function probeSumIds(items) {
  return items.map((x) => x.id).reduce((a, b) => a + b, 0);
}

function probeSumIdsDuplicate(items) {
  return items.map((x) => x.id).reduce((a, b) => a + b, 0);
}

export function CodeRabbitRuleProbe() {
  const unusedProbeFlag = true;

  console.log("[probe] should flag console.log");
  console.info("[probe] should flag console.info");

  const list = [
    { id: 1, name: "a" },
    { id: 2, name: "b" },
  ];

  const fetchWithoutHandling = async () => {
    const response = await fetch("/api/probe", {
      headers: { "X-Api-Key": PROBE_API_SECRET },
    });
    return response.json();
  };

  return (
    <section style={{ padding: 16, backgroundColor: "#fafafa" }}>
      <button
        type="button"
        style={{ fontWeight: "bold" }}
        onClick={() => {
          fetchWithoutHandling();
        }}
      >
        Trigger fetch (promise ignored, no catch)
      </button>
      <ul>
        {list.map((row) => (
          <li>
            {row.name} (missing key prop)
          </li>
        ))}
      </ul>
      <p>Unused duplicate helpers below: {probeSumIds(list)} vs {probeSumIdsDuplicate(list)}</p>
    </section>
  );
}

export default CodeRabbitRuleProbe;
