import Form from './form';

export default Form.extend({
  model(params) {
    return this.get('store').findRecord('api-scope', params.apiScopeId);
  },
});
