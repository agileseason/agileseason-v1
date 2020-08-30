import cookies from 'browser-cookies';

export default {
  set(name, key, value) {
    cookies.set(`${name}_${key}`, JSON.stringify(value), { expires: 365 });
  },
  get(name, key, defaultValue) {
    const value = cookies.get(`${name}_${key}`);

    return value ?
      JSON.parse(value) :
      defaultValue;
  }
};
