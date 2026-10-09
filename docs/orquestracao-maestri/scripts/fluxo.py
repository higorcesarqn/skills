"""Gera o painel das tasks (fluxograma Mermaid + tabela) para um portal do Maestri.

Uso:
    python -X utf8 fluxo.py <estado.json> <saida.html>

estado.json:
{
  "titulo": "PBI #3100 · Migração leva o que está pronto",
  "subtitulo": "Integradora feature/pbi-3100 · PR !764 (rascunho)",
  "final": "PR !764 sai de rascunho",          # nó final; opcional
  "finalEstado": "aguardando",                   # opcional
  "regras": ["Paralelo só com os bloqueadores integrados"],   # opcional, linhas abaixo da tabela
  "tasks": [
    {"id": "3101", "titulo": "Quadra leva lotes prontos", "bloqueadaPor": [],
     "estado": "integrada", "trabalhador": "Bussola", "sha": "5079c74a3", "nota": "tracer",
     "floor": "3101 Quadra", "branch": "task/3101-migrar-quadra"},
    {"id": "3108", "titulo": "Filtro pelo recorte", "estado": "fora", "ligadaA": ["3105"]}
  ]
}

Estados: aguardando, trabalhando, revisao, bloqueada, integrada, fora (item aberto à parte, ligado
por linha tracejada via "ligadaA"). As tasks sem dependente (exceto "fora") apontam para o nó final.
Abaixo do fluxograma vai a tabela Task / floor e branch / trabalhador / estado / SHA, do mesmo estado.json.
"""

import html
import json
import sys

CORES = {
    "integrada": ("#9be7a8", "#2f7d3e", "integrada"),
    "trabalhando": ("#ffd27a", "#a8710b", "trabalhando"),
    "revisao": ("#a9cbff", "#2b5fab", "em revisão"),
    "bloqueada": ("#ff9d9d", "#a12b2b", "bloqueada"),
    "aguardando": ("#d6d6d0", "#77776f", "aguardando"),
    "fora": ("#ececE6", "#77776f", "à parte"),
}


def rotulo(texto: str) -> str:
    return texto.replace('"', "#quot;")


def tabela(tasks: list) -> str:
    def celula(valor) -> str:
        return html.escape(str(valor)) if valor else "—"

    linhas = []
    for t in tasks:
        fundo, _, texto = CORES.get(t.get("estado", "aguardando"), CORES["aguardando"])
        floor = " / ".join(x for x in (t.get("floor"), t.get("branch")) if x)
        linhas.append(
            "<tr>"
            f"<td>#{celula(t['id'])}</td><td>{celula(t['titulo'])}</td><td><code>{celula(floor)}</code></td>"
            f"<td>{celula(t.get('trabalhador'))}</td>"
            f'<td><span class="estado" style="background:{fundo}">{texto}</span></td>'
            f"<td><code>{celula(t.get('sha'))}</code></td>"
            "</tr>"
        )
    return (
        "<table><thead><tr><th>Task</th><th>Título</th><th>Floor / branch</th><th>Trabalhador</th>"
        "<th>Estado</th><th>SHA</th></tr></thead><tbody>" + "".join(linhas) + "</tbody></table>"
    )


def no(t: dict) -> str:
    linhas = [f"#{t['id']} {t['titulo']}"]
    extra = " · ".join(x for x in (t.get("nota"), t.get("trabalhador"), t.get("sha")) if x)
    if extra:
        linhas.append(extra)
    return f'  T{t["id"]}["{rotulo("<br/>".join(linhas))}"]:::{t.get("estado", "aguardando")}'


def main(caminho_estado: str, caminho_html: str) -> None:
    with open(caminho_estado, encoding="utf-8") as f:
        estado = json.load(f)

    tasks = estado["tasks"]
    ids = {t["id"] for t in tasks}
    linhas = ["flowchart LR"] + [no(t) for t in tasks]

    tem_dependente = set()
    for t in tasks:
        for b in t.get("bloqueadaPor", []):
            if b in ids:
                linhas.append(f"  T{b} --> T{t['id']}")
                tem_dependente.add(b)
        for ligada in t.get("ligadaA", []):
            if ligada in ids:
                linhas.append(f"  T{ligada} -.-> T{t['id']}")

    if estado.get("final"):
        linhas.append(f'  FIM(["{rotulo(estado["final"])}"]):::{estado.get("finalEstado", "aguardando")}')
        for t in tasks:
            if t["id"] not in tem_dependente and t.get("estado") != "fora":
                linhas.append(f"  T{t['id']} --> FIM")

    for nome, (fundo, borda, _) in CORES.items():
        tracejado = ",stroke-dasharray:4 3" if nome == "fora" else ""
        linhas.append(f"  classDef {nome} fill:{fundo},stroke:{borda},color:#111{tracejado}")

    legenda = "".join(
        f'<span style="background:{fundo}">{texto}</span>' for fundo, _, texto in CORES.values()
    )
    regras = "".join(f"<li>{html.escape(r)}</li>" for r in estado.get("regras", []))
    regras = f'<ul class="regras">{regras}</ul>' if regras else ""
    pagina = f"""<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(estado.get("titulo", "Fluxo"))}</title>
<style>
:root{{--bg:#f7f7f5;--fg:#1d1d1b;--muted:#6b6b66;--linha:#dcdcd6}}
@media (prefers-color-scheme:dark){{:root{{--bg:#1b1b1a;--fg:#ecece8;--muted:#9a9a94;--linha:#3a3a37}}}}
body{{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:14px/1.4 system-ui,sans-serif}}
h1{{font-size:16px;margin:0 0 4px}} p{{margin:0 0 12px;color:var(--muted)}}
.legenda span{{display:inline-block;padding:2px 8px;border-radius:4px;margin-right:6px;font-size:12px;color:#111}}
.mermaid .nodeLabel,.mermaid .nodeLabel p{{color:#111!important;opacity:1!important}}
.tabela{{overflow-x:auto;margin-top:12px}}
table{{border-collapse:collapse;font-size:13px;min-width:640px}}
th,td{{text-align:left;padding:5px 10px;border-bottom:1px solid var(--linha)}}
th{{color:var(--muted);font-weight:600}}
code{{font-size:12px}}
.estado{{display:inline-block;padding:1px 8px;border-radius:4px;font-size:12px;color:#111;white-space:nowrap}}
ul.regras{{margin:12px 0 0;padding-left:18px;color:var(--muted);font-size:13px}}
</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
</head><body>
<h1>{html.escape(estado.get("titulo", ""))}</h1>
<p>{html.escape(estado.get("subtitulo", ""))}</p>
<div class="legenda">{legenda}</div>
<pre class="mermaid">
{chr(10).join(linhas)}
</pre>
<div class="tabela">{tabela(tasks)}</div>
{regras}
<script>
const dark=matchMedia('(prefers-color-scheme: dark)').matches;
mermaid.initialize({{startOnLoad:true,theme:'base',themeVariables:{{fontSize:'15px',primaryTextColor:'#111',nodeTextColor:'#111',lineColor:dark?'#c9c9c2':'#55554f',textColor:dark?'#ecece8':'#1d1d1b'}}}});
</script>
</body></html>
"""
    with open(caminho_html, "w", encoding="utf-8") as f:
        f.write(pagina)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
