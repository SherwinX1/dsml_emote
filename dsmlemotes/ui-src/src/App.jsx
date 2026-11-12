import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { asList, post } from './nui.js';

// The emote menu. Messages from client/menu.lua (unchanged contract):
//   openMenu {data}, closeMenu, playingState {playing, name}, updateFavoritesRecent {favorites},
//   walkStyleState {name}, sharedRequest {fromName, label, seconds}, sharedRequestClear
// Callbacks back: closeMenu, playEmote/playScenario/playShared {name}, stopEmote,
//   toggleFavorite {name}, setWalkStyle {name}, setWalkSpeedValue {value},
//   setWalkSpeedLimit {enabled}, acceptShared, declineShared

const TABS = [
  { key: 'animations', label: 'Animations' },
  { key: 'walk', label: 'Walk Styles' },
  { key: 'shared', label: 'Shared' },
];

const FILTERS = [
  { key: 'all', label: 'All' },
  { key: 'favorites', label: 'Favorites' },
  { key: 'dances', label: 'Dances' },
  { key: 'emotes', label: 'Emotes' },
  { key: 'props', label: 'Props' },
];

function matchesSearch(item, query) {
  if (!query) return true;
  const q = query.toLowerCase();
  const fields = [item.name, item.label, item.description, item.category, ...asList(item.tags)];
  return fields.some((f) => typeof f === 'string' && f.toLowerCase().includes(q));
}

function StarIcon({ filled }) {
  return (
    <svg viewBox="0 0 24 24" fill={filled ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round">
      <path d="m12 3.5 2.6 5.3 5.9.9-4.25 4.1 1 5.85L12 16.9l-5.25 2.75 1-5.85L3.5 9.7l5.9-.9Z" />
    </svg>
  );
}

function Row({ item, active, activeLabel, pending, favorite, onFavorite, onClick }) {
  return (
    <div
      className={`row${active ? ' is-active' : ''}${pending ? ' is-pending' : ''}`}
      title={item.description || ''}
      onClick={onClick}
    >
      <span className={`dot${active ? ' is-on' : ''}`} />
      <div className="row-main">
        <span className="row-label">{item.label}</span>
        {item.category ? <span className="row-meta">{item.category}</span> : null}
      </div>
      {active && activeLabel ? <span className="tag">{activeLabel}</span> : null}
      {onFavorite ? (
        <button
          className={`star${favorite ? ' is-on' : ''}`}
          title={favorite ? 'Remove from favorites' : 'Add to favorites'}
          onClick={(e) => {
            e.stopPropagation();
            onFavorite();
          }}
        >
          <StarIcon filled={favorite} />
        </button>
      ) : null}
    </div>
  );
}

function SharedRequest({ request }) {
  const [left, setLeft] = useState(1);

  useEffect(() => {
    if (!request) return undefined;
    const total = (request.seconds || 10) * 1000;
    const start = Date.now();
    setLeft(1);
    const id = setInterval(() => {
      const value = Math.max(0, 1 - (Date.now() - start) / total);
      setLeft(value);
      if (value <= 0) clearInterval(id);
    }, 100);
    return () => clearInterval(id);
  }, [request]);

  if (!request) return null;

  return (
    <div className="shared-overlay">
      <div className="shared-box">
        <p className="kicker">Shared emote</p>
        <p className="shared-text">
          <strong>{request.fromName}</strong> wants to {request.label} with you.
        </p>
        <div className="timer">
          <div className="timer-fill" style={{ transform: `scaleX(${left})` }} />
        </div>
        <div className="shared-buttons">
          <button className="pill pill--primary" onClick={() => request.respond('acceptShared')}>
            Accept
          </button>
          <button className="pill" onClick={() => request.respond('declineShared')}>
            Decline
          </button>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  const [open, setOpen] = useState(false);
  const [catalogue, setCatalogue] = useState(null);
  const [tab, setTab] = useState('animations');
  const [filter, setFilter] = useState('all');
  const [query, setQuery] = useState('');
  const [favorites, setFavorites] = useState(() => new Set());
  const [playing, setPlaying] = useState(null);
  const [pending, setPending] = useState(null); // sent, waiting for playingState
  const [walkStyle, setWalkStyle] = useState('default');
  const [walkSpeed, setWalkSpeed] = useState(1);
  const [walkLimit, setWalkLimit] = useState(false);
  const [sharedRequest, setSharedRequest] = useState(null);
  const pendingTimer = useRef(null);
  const searchRef = useRef(null);

  const clearPending = useCallback(() => {
    setPending(null);
    if (pendingTimer.current) clearTimeout(pendingTimer.current);
    pendingTimer.current = null;
  }, []);

  const close = useCallback(() => {
    setOpen(false);
    post('closeMenu');
  }, []);

  useEffect(() => {
    function onMessage(event) {
      const msg = event.data || {};
      switch (msg.action) {
        case 'openMenu': {
          const data = msg.data || {};
          const speed = data.walkSpeed || { min: 0.1, max: 3.0, step: 0.1, default: 1.0 };
          setCatalogue(data);
          setFavorites(new Set(asList(data.favorites)));
          setPlaying(data.playing || null);
          setWalkStyle(data.currentWalkStyle || 'default');
          setWalkSpeed(Number(data.walkSpeedValue ?? speed.default ?? 1));
          setWalkLimit(!!data.walkSpeedLimitEnabled);
          setTab('animations');
          setFilter('all');
          setQuery('');
          setOpen(true);
          break;
        }
        case 'closeMenu':
          setOpen(false);
          break;
        case 'playingState':
          clearPending();
          setPlaying(msg.playing ? msg.name : null);
          break;
        case 'updateFavoritesRecent':
          setFavorites(new Set(asList(msg.favorites)));
          break;
        case 'walkStyleState':
          setWalkStyle(msg.name || 'default');
          break;
        case 'sharedRequest':
          setSharedRequest({ ...msg, respond: (name) => { post(name); setSharedRequest(null); } });
          break;
        case 'sharedRequestClear':
          setSharedRequest(null);
          break;
        default:
          break;
      }
    }
    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, [clearPending]);

  useEffect(() => {
    if (!open) return undefined;
    const onKey = (e) => {
      if (e.key === 'Escape') close();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, close]);

  useEffect(() => {
    if (open && tab === 'animations') searchRef.current?.focus();
  }, [open, tab]);

  const animItems = useMemo(() => {
    if (!catalogue) return [];
    const emotes = asList(catalogue.emotes).map((i) => ({ ...i, kind: 'emote' }));
    const scenarios = asList(catalogue.scenarios).map((i) => ({ ...i, kind: 'scenario' }));
    return emotes.concat(scenarios).sort((a, b) => String(a.label).localeCompare(String(b.label)));
  }, [catalogue]);

  const labelByName = useMemo(() => {
    const map = {};
    animItems.forEach((i) => { map[i.name] = i.label; });
    asList(catalogue?.shared).forEach((i) => { map[i.name] = i.label; });
    return map;
  }, [animItems, catalogue]);

  const visible = useMemo(
    () =>
      animItems.filter((item) => {
        if (filter === 'favorites' && !favorites.has(item.name)) return false;
        if (filter === 'dances' && item.category !== 'Dances') return false;
        if (filter === 'props' && !item.prop) return false;
        if (filter === 'emotes' && (item.category === 'Dances' || item.prop)) return false;
        return matchesSearch(item, query);
      }),
    [animItems, filter, favorites, query]
  );

  if (!open && !sharedRequest) return null;

  const favoritesEnabled = !!catalogue?.favoritesEnabled;
  const filters = favoritesEnabled ? FILTERS : FILTERS.filter((f) => f.key !== 'favorites');
  const speedCfg = catalogue?.walkSpeed || { min: 0.1, max: 3.0, step: 0.1 };

  function play(item, endpoint) {
    if (playing === item.name && endpoint !== 'playShared') {
      post('stopEmote');
      return;
    }
    if (pending === item.name) return; // still waiting on the last click
    setPending(item.name);
    if (pendingTimer.current) clearTimeout(pendingTimer.current);
    pendingTimer.current = setTimeout(clearPending, 4000);
    post(endpoint, { name: item.name });
  }

  const toggleFavorite = (name) => post('toggleFavorite', { name });

  return (
    <>
      {open && catalogue ? (
        <div className="menu" role="dialog" aria-label="Emotes">
          <header className="header">
            <div className="titles">
              <p className="kicker">Frontier</p>
              <h1 className="title">Emotes</h1>
            </div>
            <button className="close-btn" onClick={close} aria-label="Close">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                <path d="M6 6l12 12M18 6 6 18" />
              </svg>
            </button>
          </header>

          <div className="segmented">
            {TABS.map((t) => (
              <button key={t.key} className={tab === t.key ? 'is-active' : ''} onClick={() => setTab(t.key)}>
                {t.label}
              </button>
            ))}
          </div>

          {tab === 'animations' ? (
            <div className="panel">
              <div className="search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                  <circle cx="11" cy="11" r="7" />
                  <path d="m20 20-3.5-3.5" />
                </svg>
                <input
                  ref={searchRef}
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  placeholder="Search emotes..."
                  autoComplete="off"
                  spellCheck="false"
                />
                {query ? (
                  <button className="search-clear" onClick={() => setQuery('')} aria-label="Clear search">
                    ×
                  </button>
                ) : null}
              </div>

              <div className="chips">
                {filters.map((f) => (
                  <button key={f.key} className={`chip${filter === f.key ? ' is-active' : ''}`} onClick={() => setFilter(f.key)}>
                    {f.label}
                  </button>
                ))}
              </div>

              <div className="list scroll">
                {visible.length === 0 ? (
                  <p className="empty">{filter === 'favorites' ? 'No favorites yet - tap the star on an emote.' : 'Nothing found.'}</p>
                ) : (
                  visible.map((item) => (
                    <Row
                      key={`${item.kind}:${item.name}`}
                      item={item}
                      active={playing === item.name}
                      activeLabel="Playing"
                      pending={pending === item.name}
                      favorite={favorites.has(item.name)}
                      onFavorite={favoritesEnabled ? () => toggleFavorite(item.name) : null}
                      onClick={() => play(item, item.kind === 'scenario' ? 'playScenario' : 'playEmote')}
                    />
                  ))
                )}
              </div>
            </div>
          ) : null}

          {tab === 'walk' ? (
            <div className="panel">
              <div className="walk-card">
                <div className="walk-row">
                  <span className="walk-label">Walk speed</span>
                  <span className="walk-value">{walkSpeed.toFixed(1)}</span>
                </div>
                <input
                  className="slider"
                  type="range"
                  min={speedCfg.min}
                  max={speedCfg.max}
                  step={speedCfg.step}
                  value={walkSpeed}
                  style={{ '--pct': `${((walkSpeed - speedCfg.min) / (speedCfg.max - speedCfg.min)) * 100}%` }}
                  onChange={(e) => {
                    const value = parseFloat(e.target.value);
                    setWalkSpeed(value);
                    post('setWalkSpeedValue', { value });
                  }}
                />
                <div className="walk-row walk-row--toggle">
                  <span className="walk-label">Limit walk speed</span>
                  <label className="switch">
                    <input
                      type="checkbox"
                      checked={walkLimit}
                      onChange={(e) => {
                        setWalkLimit(e.target.checked);
                        post('setWalkSpeedLimit', { enabled: e.target.checked });
                      }}
                    />
                    <span className="switch-track" />
                  </label>
                </div>
              </div>

              <div className="list scroll">
                {asList(catalogue.walkStyles).map((style) => (
                  <Row
                    key={style.name}
                    item={{ label: style.label, name: style.name }}
                    active={walkStyle === style.name}
                    activeLabel="Current"
                    onClick={() => {
                      setWalkStyle(style.name); // confirmed by walkStyleState
                      post('setWalkStyle', { name: style.name });
                    }}
                  />
                ))}
              </div>
            </div>
          ) : null}

          {tab === 'shared' ? (
            <div className="panel">
              <p className="panel-note">Ask the nearest player to do one of these with you.</p>
              <div className="list scroll">
                {asList(catalogue.shared).length === 0 ? (
                  <p className="empty">No shared emotes configured.</p>
                ) : (
                  asList(catalogue.shared).map((item) => (
                    <Row
                      key={item.name}
                      item={item}
                      pending={pending === item.name}
                      favorite={favorites.has(item.name)}
                      onFavorite={favoritesEnabled ? () => toggleFavorite(item.name) : null}
                      onClick={() => play(item, 'playShared')}
                    />
                  ))
                )}
              </div>
            </div>
          ) : null}

          <footer className="footer">
            {playing ? (
              <>
                <span className="now-playing">
                  <span className="dot is-on" />
                  <span className="now-playing-text">{labelByName[playing] || playing}</span>
                </span>
                <button className="pill pill--small pill--danger" onClick={() => post('stopEmote')}>
                  Stop
                </button>
              </>
            ) : (
              <span className="footer-idle">Pick an emote to play it</span>
            )}
            <span className="keys">
              <span className="key">ESC</span>
              <span>Close</span>
            </span>
          </footer>
        </div>
      ) : null}

      <SharedRequest request={sharedRequest} />
    </>
  );
}
