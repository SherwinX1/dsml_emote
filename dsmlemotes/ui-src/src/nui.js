// POST to a RegisterNUICallback in client/menu.lua.
const RESOURCE = typeof window.GetParentResourceName === 'function' ? window.GetParentResourceName() : 'dsmlemotes';

export function post(name, data) {
  return fetch(`https://${RESOURCE}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data ?? {}),
  }).catch(() => {});
}

// Lua tables can arrive as arrays or as objects - always work with an array.
export function asList(value) {
  if (!value) return [];
  return Array.isArray(value) ? value : Object.values(value);
}
