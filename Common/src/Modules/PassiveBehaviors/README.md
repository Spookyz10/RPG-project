# Passivas de equipamento

Crie um ModuleScript nesta pasta e use seu nome no campo `Passive` do item. O registro carrega os módulos automaticamente; não é necessário alterar `DamageHandler` nem `EquipmentPassives`.

Hooks opcionais:

| Hook | Momento / dados |
|---|---|
| `OnEquip(character, state)` | Inicializa o estado ao equipar a passiva |
| `Update(character, state)` | Atualiza timers; chamado no tick e antes do cálculo de dano |
| `OnUnequip(character, state)` | Limpa atributos/efeitos ao desequipar, morrer ou remover o personagem |
| `BeforeAttack(context, state)` | Atacante, antes do multiplicador da skill, defesa e crítico; altera `Attack`, `ForceCritical` e `CriticalMultiplier` |
| `BeforeIncomingDamage(context, state)` | Defensor, depois de crítico/defesa/modificadores; altera `Damage` |
| `OnHitConfirmed(context, state)` | Atacante, após validação/cancelamento e apenas com dano positivo; consome recursos antes de aplicar dano |
| `AfterHit(context, state)` | Atacante, após aplicar dano positivo |
| `AfterDamageReceived(context, state)` | Defensor, após receber dano positivo |

`context` contém `Caster`, `Victim`, os players correspondentes, `Damage`, `IsCrit` e `TriggeredPassives`. Este último permite que uma passiva registre no cálculo o que deve consumir em `OnHitConfirmed`, sem adicionar campos específicos no DamageHandler. Hooks de cálculo podem ser chamados sem que o dano seja aplicado; não consuma recursos neles.

Cada passiva tem seu próprio `state`. A mesma passiva equipada mais de uma vez executa uma vez por hook. Mudar seus itens de origem reinicia apenas o estado dela. Outras passivas mantêm seu estado.

Hooks executam por `Priority` decrescente (padrão 0), depois nome em ordem alfabética. Devem ser síncronos, sem `task.wait`, chamadas remotas ou outras operações que cedam execução. Buffs acumulativos precisam definir explicitamente como se combinam nessa ordem.

Exemplo:

```lua
return {
    BeforeIncomingDamage = function(context)
        local humanoid = context.Victim:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health >= humanoid.MaxHealth * 0.7 then
            context.Damage *= 0.85
        end
    end,
}
```

Validação: `tools/verify_equipment.py --luau PATH_TO_LUAU`.
