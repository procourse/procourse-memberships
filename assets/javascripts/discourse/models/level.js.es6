import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax('/league/levels');
  },

  findById(id) {
    return ajax(`/league/l/${id}`);
  }
};