import { ajax } from 'discourse/lib/ajax';

export default {
  findAll(user_id) {
    return ajax(`/league/transactions/${user_id}`);
  },

  findById(user_id, id) {
    return ajax(`/league/transactions/${user_id}/${id}`);
  }
};