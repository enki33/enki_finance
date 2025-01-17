-- Subcategories RLS policies
CREATE POLICY "Usuarios pueden ver subcategorías" ON public.subcategory 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden crear subcategorías" ON public.subcategory 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar subcategorías" ON public.subcategory 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar subcategorías" ON public.subcategory 
    FOR DELETE USING (auth.role() = 'authenticated');

-- Jars RLS policies
CREATE POLICY "Usuarios pueden ver jars" ON public.jar 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden crear jars" ON public.jar 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar jars" ON public.jar 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar jars" ON public.jar 
    FOR DELETE USING (auth.role() = 'authenticated'); 