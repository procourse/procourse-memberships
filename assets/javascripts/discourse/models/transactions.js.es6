import { ajax } from 'discourse/lib/ajax';

export default {
  findAll(user_id) {
    return ajax(`/memberships/transactions/${user_id}`);
  },

  findById(user_id, id) {
    return ajax(`/memberships/transactions/${user_id}/${id}`);
  }
};