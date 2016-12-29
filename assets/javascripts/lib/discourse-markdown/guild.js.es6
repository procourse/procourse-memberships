import { registerOption } from 'pretty-text/pretty-text';

registerOption((siteSettings, opts) => {
  console.log(opts);
  opts.features.guild = true;
});

function replaceGuild(text) {
  text = text || "";
  while (text !== (text = text.replace(/\[guild=([^\]]+)\]((?:(?!\[guild=[^\]]+\]|\[\/guild\])[\S\s])*)\[\/guild\]/ig, function (match, p1, p2) {
    return `<button class="btn-primary create btn">${p2}</button>`;
  })));
  return text;
}

export function setup(helper) {
  helper.whiteList(['button']);
  helper.addPreProcessor(text => replaceGuild(text));
}