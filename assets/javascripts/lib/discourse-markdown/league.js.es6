import { registerOption } from 'pretty-text/pretty-text';

registerOption((siteSettings, opts) => {
  opts.features.league = true;
});

function replaceLeague(text) {
  text = text || "";
  while (text !== (text = text.replace(/\[league=([^\]]+)\]((?:(?!\[league=[^\]]+\]|\[\/league\])[\S\s])*)\[\/league\]/ig, function (match, p1, p2) {
    return `<button class="btn-primary create btn">${p2}</button>`;
  })));
  return text;
}

export function setup(helper) {
  helper.whiteList(['button']);
  helper.addPreProcessor(text => replaceLeague(text));
}