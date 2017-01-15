import { registerOption } from 'pretty-text/pretty-text';

registerOption((siteSettings, opts) => {
  opts.features.league = true;
});

function replaceButton(text) {
  text = text || "";
  while (text !== (text = text.replace(/\[button=([^\]]+)\]((?:(?!\[button=[^\]]+\]|\[\/button\])[\S\s])*)\[\/button\]/ig, function (match, p1, p2) {
    return `<a href="${p1}" class="btn-primary create btn">${p2}</a>`;
  })));
  return text;
}

export function setup(helper) {
  helper.whiteList(['button', 'a[class]']);
  helper.addPreProcessor(text => replaceButton(text));
}