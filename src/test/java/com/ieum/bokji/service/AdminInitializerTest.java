package com.ieum.bokji.service;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.ieum.bokji.mapper.AdminMapper;
import java.lang.reflect.Field;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class AdminInitializerTest {

    private final List<String> inserted = new ArrayList<>();

    private AdminInitializer init(int existing) throws Exception {
        AdminMapper m = (AdminMapper) Proxy.newProxyInstance(getClass().getClassLoader(), new Class[]{AdminMapper.class},
                (p, method, a) -> {
                    if (method.getName().equals("count")) return existing;
                    if (method.getName().equals("insert")) { inserted.add((String) a[1]); return 1; }
                    return null;
                });
        AdminInitializer ai = new AdminInitializer();
        Field f = AdminInitializer.class.getDeclaredField("adminMapper");
        f.setAccessible(true);
        f.set(ai, m);
        return ai;
    }

    @Test
    public void noPasswordCreatesNothing() throws Exception {
        assertFalse(init(0).createIfEmpty(null));
        assertFalse(init(0).createIfEmpty("  "));
        assertTrue(inserted.isEmpty());
    }

    @Test
    public void existingAccountIsUntouched() throws Exception {
        assertFalse(init(1).createIfEmpty("anything"));
        assertTrue(inserted.isEmpty());
    }

    @Test
    public void emptyDbWithPasswordCreatesHashedAccount() throws Exception {
        assertTrue(init(0).createIfEmpty("test-only-pw"));
        assertEquals(1, inserted.size());
        assertTrue(new BCryptPasswordEncoder().matches("test-only-pw", inserted.get(0)));
    }
}
